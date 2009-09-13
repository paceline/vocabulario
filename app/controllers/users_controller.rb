class UsersController < Clearance::UsersController
  
  # Filters
  before_filter :users_only, :only => [:show]
  before_filter :admin_only, :only => [:admin, :destroy]
  before_filter :get_user, :only => [:edit, :update]
  
  # Make user an admin (one way only)
  def admin
    @user = User.find(params[:id])
    @user.admin = true
    @user.save
    flash[:notice] = "#{@user.name} is now an admin."
    redirect_to user_path(@user.permalink)
  end
  
  # Destroy user (entirely)
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path
  end
  
  # Edit user profile
  def edit
    @user = User.find(params[:id])
    redirect_to @user unless current_user == @user
  end
  
  # List users
  def index
    @users = User.find(:all, :order => 'name')
  end
  
  # FIX ME - copy/paste from clearance until I can find the routing error
  def password
    @user = User.find_by_id_and_confirmation_token(params[:id], params[:token])
    if @user.update_password(params[:user][:password], params[:user][:password_confirmation])
      @user.confirm_email!
      sign_in(@user)
      flash[:success] = "Password has now been changed."
      redirect_to '/'
    else
      render :template => 'passwords/edit'
    end
  end

  # Show user profile and stats
  def show
    @user = User.find_by_permalink(params[:id])
  end

  # Update user profile
  def update
    @user = User.find(params[:id])
    redirect_to @user unless current_user == @user
    begin
      @user.update_attributes!(params[:user])
      flash[:success] = "Your profile has been successfully updated."
    rescue
    end
    render(:action => 'edit')
  end
  
  protected
    def get_user
      if signed_in_as_admin?
        @user = User.find(params[:id])
      elsif signed_in?
        @user = current_user
      end
    end
end
