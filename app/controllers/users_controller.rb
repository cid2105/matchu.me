class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :correct_user?, :only => [:edit, :update, :destroy]
  # after_filter :reinit_cycle, :only => [:like, :prev, :next]

  def like
    @likee = User.find_by_uid(params[:uid])
    current_user.like!(@likee)
    current_user.decrement_index
    
    if current_user.is_new_match?(@likee)
      @match = Match.create_matches(current_user, @likee) 
      @new_match_count = current_user.new_match_count
      current_user.remove_match_uid(@likee.uid)
      reinit_cycle
      render "match" 
    else 
      reinit_cycle
      render "cycle"
    end

  end

  def search
    @users = User.search(params[:searched_name]) 
    if @users.size > 0
      @user, @center_image_uid, idx = @users.first, @users.first.uid, $redis.hget("uids", @users.first.uid)
      current_user.update_attributes(index: idx.to_i)
      @thumb_uids = current_user.thumb_uids(idx.to_i)
      render :cycle
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
    render :cycle
  end

  def reset_new_match_count
    Match.zero_match_count_for_user(current_user)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to root_path
  end

  def reinit_cycle
    @user = User.find_by_uid(current_user.view_list.at(current_user.index))
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
