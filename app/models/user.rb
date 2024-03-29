class User < ActiveRecord::Base
  include PgSearch
  rolify
  
  serialize :view_list, Array
  serialize :friends, Hash  

  attr_accessible :role_ids, :as => :admin
  attr_accessible :provider, :uid, :name, :email, :friends, :view_list, :index, :school, :year, :major

  has_many :likes, :foreign_key => "liker_id"
  has_many :liked_users, :through => :likes, :source => :liked, :foreign_key => "likee_id"

  has_many :inverse_likes, :foreign_key => "likee_id", :class_name => "Like"
  has_many :liked_by_users, :through => :inverse_likes, :source => :liker, :foreign_key => "liker_id"
  
  has_many :matches
  has_many :matched_users, :through => :matches, :source => :matched_user
  # has_many :matches, :class_name => 'Match', :foreign_key => 'user_id'  

  pg_search_scope :search, :against => {:name => 'A', :email => 'B'}, :using => {:tsearch => {:dictionary => "english", :prefix => true}}
  scope :autocomplete, lambda { |term| where("name ILIKE '%#{term}%'") } 
  after_create :map_uid_to_index

  def self.all_but_my_uid(uid)
    where(['uid not in (?)', uid]).pluck("uid")
  end

  def self.find_by_id_set(id_set)
    find_each = lambda {|user_id| find(user_id) }
    id_set.map(&find_each)
  end

  def self.find_by_id_set_and_get_uid(id_set)
    find_each = lambda {|user_id| find(user_id).uid if exists?(user_id) }
    id_set.map(&find_each)
  end

  def self.create_with_omniauth(auth)
    
    unless User.exists?(uid: auth['uid'])
      @user = User.create(provider: auth['provider'], uid: auth['uid'], view_list: User.pluck("id") )
    else
      @user = User.find_by_uid(auth['uid'])
      @user.update_attributes(view_list: User.pluck("id"))
    end

    if auth['info'] 
        @user.name = auth['info']['name'] || ""
        @user.email = auth['info']['email'] || ""
        @user.save
    end
    @user.delay.add_fb_friends(auth['credentials']['token'])
    @user
  end

  def remove_match_uid(uid)
    new_view_list = view_list
    new_view_list.delete(uid)
    update_attributes(view_list: new_view_list)
  end

  def thumb_uids(idx = self.index)
    start, fin = (idx-10), (idx-1)
    arr = view_list
    (start..fin).to_a.each_with_index.map { |x,i| [arr[x], x] }
  end

  def increment_index
    update_attributes(index: (self.index + 1) % (view_list.count))
  end

  def decrement_index
    update_attributes(index: (self.index - 1) % (view_list.count))
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

  def reinit_view_list
    all_that_like_me = Like.where(likee_id: self.id).pluck("liker_id")
    all_that_dont_like_me = (User.pluck("id") - all_that_like_me).shuffle
    head_size = all_that_like_me.count
    all_that_dont_like_me_head, all_that_dont_like_me_rest = all_that_dont_like_me.partition.each_with_index { |i, x| x < (head_size) }
    new_view_list = ((all_that_dont_like_me_head | all_that_like_me).shuffle + all_that_dont_like_me_rest.shuffle) - matches.pluck("match_id") - [id]
    new_view_list = User.find_by_id_set_and_get_uid(new_view_list)
    self.update_attributes(view_list: new_view_list, index: 0)
  end

  def add_fb_friends(token)
    @facebook = Koala::Facebook::API.new(token)
    friends_hash = Hash.new
 
    @facebook.get_connections("me", "friends", :fields => "name, email, id, education").each do |hash|
      if hash.has_key? 'education' and hash['education'].length > 1 and hash['education'][1].has_key? 'school' and hash['education'][1]['school'].has_key? 'name' and  ( hash['education'][1]['school']['name'] == "Columbia University" or hash['education'][1]['school']['name'].downcase.split.include? "barnard" )
        college = hash['education'][1]
        major = (college.has_key? 'concentration')? college['concentration'].map {|c| c['name']}.join(' ') : nil        
        year = (college.has_key?('year')) ? college['year']['name'] : nil
        next if not year.nil? and year.to_i < 2011
        school =  hash['education'][1]['school']['name']
        index = rand(User.count)
        
        unless User.exists?(uid: hash['id'])
          User.create(name: hash['name'], uid: hash['id'], school: school, major: major, year: year, index: index)
        end

        friends_hash[hash['name']] = hash['id']
      end
    end

    update_attributes(friends: friends_hash)
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
    (likee.likes? self and not self.matches.pluck("match_id").include? likee.id and likee.id != self.id)
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
    ($redis.hget "new_match_count", id).to_i || 0
  end

  def self.to_autocomplete(term)
    arr = []
    autocomplete(term).each { |user| arr.push(Hash["id", user.id, "value", user.id, "label",  user.to_s, "uid", user.uid, "name", user.to_s, "avatar", user.thumbnail, "idx", $redis.hget("uids", user.uid), "link", Rails.application.routes.url_helpers.user_path(user)]) }
    arr.first(10)
  end

  def reinit_index
    update_attributes(index: rand(User.count))
  end

  def map_uid_to_index
    idx = $redis.hlen "uids"
    $redis.hset "uids", self.uid, idx
  end

end
