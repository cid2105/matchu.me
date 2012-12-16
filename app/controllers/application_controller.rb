class ApplicationController < ActionController::Base
  layout 'authenticated'

  protect_from_forgery
  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?
  helper_method :uid_to_thumbnail
  helper_method :uid_to_image

  def uid_to_thumbnail(uid)
    uid_to_image uid, "square"
  end

  def uid_to_image(uid, size)
    "http://graph.facebook.com/#{uid}/picture?type=#{size}"
  end

  private

    def current_user
      begin
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      rescue Exception => e
        nil
      end
    end

    def user_signed_in?
      return true if current_user
    end

    def correct_user?
      @user = User.find(params[:id])
      unless current_user == @user
        redirect_to root_url, :alert => "Access denied."
      end
    end

    def authenticate_user!
      if !current_user
        @match_count = Match.count / 2 + 1
        render 'home/unauthenticated', :layout => 'unauthenticated' 
      end
    end


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

end
