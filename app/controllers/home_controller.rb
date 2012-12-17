class HomeController < ApplicationController
	before_filter :authenticate_user!
  	
  	def index  		
  		puts current_user.name
  		@user = User.find_by_uid(current_user.view_list.at(current_user.index))
  		@center_image_uid = @user.uid
  		@thumb_uids = current_user.thumb_uids
  		@matches = current_user.matches.paginate(:page => params[:page], :per_page => 8)
  	end


end
