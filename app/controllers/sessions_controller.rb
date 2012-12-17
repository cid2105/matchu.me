class SessionsController < ApplicationController

  def new
    redirect_to '/auth/facebook'
  end


  def create
    auth = request.env["omniauth.auth"]

    redirect_to root_url, :notice => 'Only Columbia or Barnard students can join' if auth.has_key? 'education' and hash['education'].length > 1 and hash['education'][1].has_key? 'school' and hash['education'][1]['school'].has_key? 'name' and  ( hash['education'][1]['school']['name'] == "Columbia University" or hash['education'][1]['school']['name'].downcase.split.include? "barnard" )
    
    if User.exists?(:provider => auth['provider'], :uid => auth['uid'].to_s)
      user = User.where(:provider => auth['provider'], :uid => auth['uid'].to_s).first
    else
      user =   User.create_with_omniauth(auth)
    end
    
    Resque.enqueue(AddFbFriends, user.id, auth['credentials']['token']) if user.friends.nil?
    user.reinit_view_list
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
