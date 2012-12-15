class View < ActiveRecord::Base
  attr_accessible :viewed_id, :viewer_id
  belongs_to :user
  belongs_to :viewer, :class_name => 'User'
end
