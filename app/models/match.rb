class Match < ActiveRecord::Base
  attr_accessible :match_id, :user_id
  belongs_to :user
  belongs_to :matchee, :class_name => 'User'

  def self.create_matches(user_a, user_b)
  	@match = user_a.matches.create(match_id: user_b.id)
    user_b.matches.create(match_id: user_a.id)
    Resque.redis.hincrby "new_match_count", user_a.id, 1
    Resque.redis.hincrby "new_match_count", user_b.id, 1
    return @match
  end

  def self.zero_match_count_for_user(user)
  	Resque.redis.hset "new_match_count", user.id, 0
  end

  def matchee
  	User.find(match_id)
  end

end
