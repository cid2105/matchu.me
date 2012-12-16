class User < ActiveRecord::Base
  include PgSearch
  rolify
  
  serialize :unseen, Array
  serialize :friends, Hash  

  attr_accessible :role_ids, :as => :admin
  attr_accessible :provider, :uid, :name, :email, :friends, :unseen, :index, :school, :year, :major

  has_many :likes, :class_name => 'Like', :foreign_key => 'liker_id'
  has_many :likers, :class_name => 'Like', :foreign_key => 'likee_id' 
  has_many :viewed_users, :class_name => 'View', :foreign_key => 'viewer_id'
  has_many :viewers, :class_name => 'View', :foreign_key => 'viewee_id' 
  has_many :matches, :class_name => 'Match', :foreign_key => 'user_id'  

  pg_search_scope :search, :against => {:name => 'A', :email => 'B'}, :using => {:tsearch => {:dictionary => "english", :prefix => true}}
  scope :autocomplete, lambda { |term| where("name ILIKE '%#{term}%'") } 
  after_create :map_uid_to_index

  def self.all_but_my_uid(uid)
    where(['uid not in (?)', uid]).pluck("uid")
  end

  def self.create_with_omniauth(auth)
    @user = User.create(provider: auth['provider'], uid: auth['uid'])
    if auth['info'] 
        @user.name = auth['info']['name'] || ""
        @user.email = auth['info']['email'] || ""
        @user.save
    end
    Resque.enqueue(AddFbFriends, @user.id, auth['credentials']['token'])
    @user
  end

  def thumb_uids(idx = self.index)
    start, fin = (idx-10), (idx-1)
    arr = User.pluck("uid")
    (start..fin).to_a.each_with_index.map { |x,i| [arr[x], x] }
  end

  def increment_index
    update_attributes(index: (self.index + 1) % User.count)
  end

  def decrement_index
    update_attributes(index: (self.index - 1) % User.count)
  end

  def education
    "#{school} #{year}"
  end

  def thumbnail
    image("small")
  end

  def image(size)
    "http://graph.facebook.com/#{uid}/picture?type=#{size}"
  end

  def reinit_unseen
    User.pluck("uid").shuffle
  end

  def to_s
    name
  end

  def like!(likee)
    likes.create(likee_id: likee.id) unless likes?(likee)
  end

  def likes?(likee)
    likes.pluck("likee_id").include?(likee.id)
  end

  def is_new_match?(likee)
    (likee.likes? self and not self.matches.pluck("match_id").include? likee.id)
  end

  def view!(other)
    viewed_users.create(viewed_id: other.id) unless likes?(likee)
  end

  def viewed?(other)
    viewed_users.include?(other)
  end

  def match!(matched)
    matches.create(match_id: matched.id)
  end

  def new_match_count
    (Resque.redis.hget "new_match_count", id).to_i || 0
  end

  def remove_seen(seen)
    self.unseen.delete seen
    self.update_attributes(unseen: unseen)
  end

  def self.to_autocomplete(term)
    arr = []
    autocomplete(term).each { |user| arr.push(Hash["id", user.id, "value", user.id, "label",  user.to_s, "uid", user.uid, "name", user.to_s, "avatar", user.thumbnail, "idx", Resque.redis.hget("uids", user.uid), "link", Rails.application.routes.url_helpers.user_path(user)]) }
    arr.first(10)
  end

  def reinit_index
    update_attributes(index: rand(User.count))
  end

  def map_uid_to_index
    idx = Resque.redis.hlen "uids"
    Resque.redis.hset "uids", self.uid, idx
  end

end
