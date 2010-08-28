class UsersController < Clearance::UsersController
  
  # Filters
  before_filter :browser_required, :except => [:current, :index, :show, :statistics]
  before_filter :web_service_authorization_required, :only => [:current, :index, :show]
  before_filter :login_required, :except => [:create, :index, :new]
  before_filter :admin_required, :only => [:admin, :destroy]
  
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
    @user = current_user.admin ? User.find_by_id_or_permalink(params[:id]) : current_user
    redirect_to user_path(@user.permalink) unless current_user == @user || current_user.admin
  end
  
  # List users
  #
  # API information - 
  #   /users.xml|json (Oauth required)
  def index
    @users = User.find(:all, :order => 'name')
    @lists = List.find_public(current_user)
    respond_to do |format|
      format.html
      format.json { render :json => @users.to_json(:except => [:user_id, :confirmation_token, :encrypted_password, :email, :email_confirmed, :remember_token, :salt]) }
      format.xml { render :xml => @users.to_xml(:except => [:user_id, :confirmation_token, :encrypted_password, :email, :email_confirmed, :remember_token, :salt]) }
    end
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
  #
  # API information - 
  #   /users/#{id|permalink}.xml|json (Oauth required)
  def show
    begin
      @user = User.find_by_id_or_permalink(params[:id])
      respond_to do |format|
        format.html
        format.json { render :json => current_user == @user || current_user.admin ? @user.to_json(:except => [:user_id, :confirmation_token, :encrypted_password, :email_confirmed, :remember_token, :salt], :methods => :profile_url) : @user.to_json(:except => [:user_id, :confirmation_token, :encrypted_password, :email, :email_confirmed, :remember_token, :salt], :methods => :profile_url) }
        format.xml { render :xml => current_user == @user || current_user.admin ? @user.to_xml(:except => [:user_id, :confirmation_token, :encrypted_password, :email_confirmed, :remember_token, :salt], :methods => :profile_url) : @user.to_xml(:except => [:user_id, :confirmation_token, :encrypted_password, :email, :email_confirmed, :remember_token, :salt], :methods => :profile_url) }
      end
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    end
  end
  
  # Show user profile and stats
  #
  # API information - 
  #   /users/current.xml|json (Oauth required)
  def current
    respond_to do |format|
      format.json { render :json => current_user.to_json(:except => [:confirmation_token, :encrypted_password, :email_confirmed, :remember_token, :salt], :methods => :profile_url) }
      format.xml { render :xml => current_user.to_xml(:except => [:confirmation_token, :encrypted_password, :email_confirmed, :remember_token, :salt], :methods => :profile_url) }
    end
  end
  
  # Statistics page
  # FIX ME - There's probably a better way to do this - i.e. this needs to be cleaned up
  def statistics
    @user = User.find_by_id_or_permalink(params[:id])
    if current_user == @user
      @tags = Score.tag_counts(:conditions => ["scores.user_id = ?", @user.id])
    
      if !params[:tag].blank?
        @tag = Tag.find_by_id_or_permalink(params[:tag])
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
    else
      redirect_to user_path(@user.permalink)
    end
  end
  
  # Update user profile
  def update
    @user = User.find_by_id_or_permalink(params[:id])
    redirect_to user_path(@user.permalink) unless current_user == @user
    begin
      @user.update_attributes!(params[:user])
      flash.now[:success] = "Your profile has been successfully updated."
    rescue
    end
    render :edit
  end
  
end
