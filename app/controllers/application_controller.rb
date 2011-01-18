class ApplicationController < ActionController::Base
  # Defaults
  protect_from_forgery
  
  # Layout
  layout 'default', :except => [:apply_tags, :apply_type, :live, :options_for_list, :print, :sort, :tab, :tabs]
  
  # Security Features - Include Clearance
  include Clearance::Authentication
  
  # Security Features - Admin check
  helper_method :signed_in_as_admin?
  def signed_in_as_admin?
    signed_in? && current_user.admin?
  end
  
  # Security Festures - Alias for OAuth plugin
  alias logged_in? signed_in?
  
  def login_required
    deny_access("Please Login or Create an Account to Access that Feature.") unless signed_in?
  end

  def admin_required
    deny_access("Please Login as an administrator to Access that Feature.") unless signed_in_as_admin?
  end
  
  # Ensure compatability with OAuth plugin
  def authorized?
    true
  end
  
  # Ensure compatability with OAuth plugin
  def current_user
    @current_user ||= user_from_cookie
  end
  
  # Error handlers - 401
  def unauthorized
    respond_to do |format|
      format.html { redirect_to '/login' }
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
    def browser_required
      invalid_request unless !params.key?(:format) || params[:format] == 'js' || params[:format] == 'html'
    end

    def web_service_authorization_required
      login_or_oauth_required if ['json','xml'].include?(params[:format])
    end
end
