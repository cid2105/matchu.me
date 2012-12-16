class SessionsController < ApplicationController

  def new
    redirect_to '/auth/facebook'
  end


  def create
    auth = request.env["omniauth.auth"]

    user = User.where(:provider => auth['provider'], :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
    
    Resque.enqueue(AddFbFriends, user.id, auth['credentials']['token']) if user.friends.nil?
    user.reinit_view_list

    user.add_role :admin if User.count == 1 # make the first user an admin
    
    user.reinit_index
    
    session[:user_id] = user.id
    
    if user.email.blank?
      redirect_to edit_user_path(user), :alert => "Please enter your email address."
    else
      redirect_to root_url, :notice => 'Signed in!'
    end

  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end

end
