class Like < ActiveRecord::Base
  attr_accessible :likee_id, :liker_id
  belongs_to :user
  belongs_to :liker, :class_name => 'User', :foreign_key => "liker_id"
  belongs_to :liked, :class_name => "User", :foreign_key => "likee_id"

end
