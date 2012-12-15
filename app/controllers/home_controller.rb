class HomeController < ApplicationController
	before_filter :authenticate_user!
  	
  	def index
  		idx = current_user.index
  		@center_image_uid = User.find(idx).uid
  		@thumb_uids = User.find(((idx-10)..(idx-1)).to_a).map(&:uid)
  	end

end
