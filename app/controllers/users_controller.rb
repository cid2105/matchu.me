class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :correct_user?, :only => [:edit, :update]
  # after_filter :reinit_cycle, :only => [:like, :prev, :next]

  def like
    @likee = User.find_by_uid(params[:uid])
    current_user.like!(@likee)
    current_user.decrement_index
    reinit_cycle
    
    if current_user.is_new_match?(@likee)
      @match = Match.create_matches(current_user, @likee) 
      @new_match_count = current_user.new_match_count
      render "match" 
    else 
      render "cycle"
    end

  end

  def search
    @users = User.search(params[:term]).where(:active => true).paginate(:page => params[:page], :per_page => 10)
    @sidebar = true 
    respond_to do |format|
      format.html
      format.js { render :json => @users }
    end
  end

  def autocomplete
    render :json => User.to_autocomplete(params[:term])
  end

  def index
    @users = User.all
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to @user
    else
      render :edit
    end
  end

  def prev
    current_user.increment_index
    reinit_cycle
    render :cycle
  end

  def next
    current_user.decrement_index
    reinit_cycle
    render :cycle
  end

  def goto
    @user = User.find_by_uid(params[:uid])
    @center_image_uid = @user.uid
    current_user.update_attributes(index: params[:idx].to_i)
    @thumb_uids = current_user.thumb_uids(params[:idx].to_i)
    @matches = current_user.matches.map{ |u| User.find(u.match_id) }
    render :cycle
  end

  def reset_new_match_count
    Match.zero_match_count_for_user(current_user)
  end

  def show
    @user = User.find(params[:id])
  end

  def reinit_cycle
    @user = User.all.to_a.at(current_user.index)
    @center_image_uid = @user.uid
    @thumb_uids = current_user.thumb_uids
  end

  private

  def remove_seen
    # current_user.remove_seen params[:uid]
    # current_user.reinit_unseen if current_user.unseen.size < 11
    reinit_cycle
  end

  

end
