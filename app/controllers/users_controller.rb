class UsersController < ApplicationController
  
  # Filters
  before_filter :browser_required, :except => [:current, :index, :show]
  before_filter :authorization_for_web_services_required, :only => [:current, :index, :show]
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
     rescue ActiveRecord::RecordNotFound
        file_not_found
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
  
  # Sets defaults for language pair
  def defaults
    @user = User.find_by_id_or_permalink(params[:id])
    redirect_to user_path(@user.permalink) unless current_user == @user
    begin
      @user.update_attributes!(params[:user])
      flash.now[:notice] = "Your preferences have been successfully saved."
    rescue
      internal_server_error
    end
    render :partial => 'layouts/flashes'
  end
end
