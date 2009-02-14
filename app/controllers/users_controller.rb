class UsersController < ApplicationController  

  before_filter :login_required, :except => [:home, :new, :create]
  before_filter :get_target, :only => [:invite, :accept, :reject, :revoke, :unfriend]

  def home
    if logged_in?
      
    else
      render :action => 'generic_home'
    end
  end

  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
            # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry."
      render :action => 'new'
    end
  end
  
  # GET /users/1/friends
  def friends
    @user = User.find(params[:user_id])
    @friends = @user.friends
  end
  
  # POST /users/1/invite/1
  def invite
    flash[:notice] = current_user.invite(@target)
    redirect_to home_user_path(current_user)
  end
  
  # PUT /users/1/accept/1
  def accept
    flash[:notice] = current_user.accept_invite_from(@target)
    redirect_to home_user_path(current_user)
  end
  
  # PUT /users/1/reject/1
  def reject
    flash[:notice] = current_user.reject_invite_from(@target)
    redirect_to home_user_path(current_user)
  end
  
  # PUT /users/1/revoke/1
  def revoke
    flash[:notice] = current_user.revoke_invite_to(@target)
    redirect_to home_user_path(current_user)
  end
  
  # DELETE /users/1/unfriend/1
  def unfriend
    flash[:notice] = current_user.remove_friend(@target)
    redirect_to home_user_path(current_user)
  end
  
protected

  def get_target
    @target = User.find(params[:id])
  end
  
  
end
