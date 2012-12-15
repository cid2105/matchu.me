class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :correct_user?, :only => [:edit, :update]
  # after_filter :reinit_cycle, :only => [:like, :prev, :next]

  def like
    @likee = User.find_by_uid(params[:uid])
    current_user.like!(@likee)
    current_user.update_attributes(index: current_user.index + 1)
    reinit_cycle
    render :cycle
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

  def next
    current_user.update_attributes(index: current_user.index + 1)
    reinit_cycle
    render :cycle
  end

  def prev
    current_user.update_attributes(index: current_user.index - 1)
    reinit_cycle
    render :cycle
  end

  def show
    @user = User.find(params[:id])
  end

  def reinit_cycle
    idx = current_user.index
    @center_image_uid = User.find(idx).uid
    @thumb_uids = User.find(((idx-10)..(idx-1)).to_a).map(&:uid)
  end

  private

  def remove_seen
    # current_user.remove_seen params[:uid]
    # current_user.reinit_unseen if current_user.unseen.size < 11
    reinit_cycle
  end

  

end
