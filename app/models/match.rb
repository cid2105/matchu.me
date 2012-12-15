class Match < ActiveRecord::Base
  attr_accessible :match_id, :user_id
  belongs_to :user
  belongs_to :matchee, :class_name => 'User'
end
