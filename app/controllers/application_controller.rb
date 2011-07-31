class ApplicationController < ActionController::Base
  
  # Alias
  alias :logged_in? :user_signed_in?
  alias :login_required :authenticate_user!
  
  # Defaults
  protect_from_forgery
  
  # Layout
  layout 'default', :except => [:apply_tags, :apply_type, :live, :options_for_list, :sort, :tab, :tabs]
  
  # Security Features - Admin check
  helper_method :signed_in_as_admin?
  def signed_in_as_admin?
    current_user.try(:admin?)
  end
  
  # Set current user (required for oauth-plugin)
  def current_user=(user)
    current_user = user
  end
  
  # Error handlers - 401
  def unauthorized
    respond_to do |format|
      format.html { redirect_to '/users/sign_in' }
      format.json { render :json => { :error => { :status => '401', :message => "You're not authorized to access this page. Sorry." } }, :status => 401 }
      format.xml { render :xml => { :status => '401', :message => "You're not authorized to access this page. Sorry." }.to_xml(:root => 'error'), :status => 401 }
    end
  end
  
  # Error handlers - 404
  def file_not_found
    respond_to do |format|
      format.html { render :file => "#{::Rails.root.to_s}/public/404.html", :status => 404 }
      format.json { render :json => { :error => { :status => '404', :message => 'No matching record found. Sorry.' } }, :status => 404 }
      format.xml { render :xml => { :status => '404', :message => 'No matching record found. Sorry.' }.to_xml(:root => 'error'), :status => 404 }
    end
  end
  
  # Error handlers - 406
  def invalid_request
    respond_to do |format|
      format.html { render :file => "#{::Rails.root.to_s}/public/406.html", :status => 406 }
      format.json { render :json => { :error => { :status => '406', :message => "Your request wasn't acceptable. Could be a missing parameter or unsupported format." } }, :status => 406 }
      format.xml { render :xml => { :status => '406', :message => "Your request wasn't acceptable. Could be a missing parameter or unsupported format." }.to_xml(:root => 'error'), :status => 406 }
    end
  end
  
  # Error handlers - 500
  def internal_server_error
    respond_to do |format|
      format.html { render :file => "#{::Rails.root.to_s}/public/500.html", :status => 500 }
      format.json { render :json => { :error => { :status => '500', :message => "Something went wrong. Sorry. Could be our fault, too." } }, :status => 500 }
      format.xml { render :xml => { :status => '500', :message => "Something went wrong. Sorry. Could be our fault, too." }.to_xml(:root => 'error'), :status => 500 }
    end
  end
  
  # Filters
  private
    def admin_required
      redirect_to root_path, :alert => 'You have to be an admin to access this feature.' unless signed_in_as_admin?
    end
    def browser_required
      invalid_request unless !params.key?(:format) || params[:format] == 'js' || params[:format] == 'html'
    end
    def authorization_for_web_services_required
      oauth_required if params[:format] == 'json' && params[:format] == 'xml'
    end
end
