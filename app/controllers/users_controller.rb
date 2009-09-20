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
  
  # Statistics page
  # FIX ME - There's probably a better way to do this - i.e. this needs to be cleaned up
  def statistics
    @user = User.find_by_permalink(params[:id])
    @tags = Score.tag_counts(:conditions => ["scores.user_id = ?", @user.id])
    
    if !params[:tag].blank?
      @tag = Tag.find_by_permalink(params[:tag])
      @page = params[:page].to_i == 0 ? Score.last_page_number(['user_id = ? AND taggings.tag_id = ?', @user.id, @tag.id], [ :taggings ]) : params[:page]
      @scores = Score.paginate_by_user_id @user.id, :conditions => ['taggings.tag_id = ?', @tag.id], :include => [ :taggings ], :page => @page, :per_page => 25
    elsif !params[:type].blank?
      @page = params[:page].to_i == 0 ? Score.last_page_number(['user_id = ? AND test_type = ?', @user.id, params[:type]]) : params[:page]
      @scores = Score.paginate_by_user_id @user.id, :conditions => ['test_type = ?', params[:type]], :page => @page, :per_page => 25
    else
      @page = params[:page].to_i == 0 ? Score.last_page_number(['user_id = ?', @user.id]) : params[:page]
      @scores = Score.paginate_by_user_id @user.id, :page => @page, :per_page => 25
    end
    
    respond_to do |format|
      format.html {
        if request.post?
          render :update do |page|
            page.replace_html 'description', render(:partial => 'statistics_message', :locals => { :tag => params[:tag], :type => params[:type] })
            page.replace_html 'graph_navigation', render(:partial => 'statistics_navigation', :locals => { :tag => params[:tag], :type => params[:type] })
          end
        else
          render :action => 'statistics'
        end
      }
      format.json { render :json => { :scores => @scores, :page => @page } }
    end
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
