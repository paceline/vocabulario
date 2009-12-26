# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  # Defaults
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # Layout
  layout 'default', :except => [:live, :print]
  
  # Security Features - Include Clearance
  include Clearance::Authentication
  
  # Security Features - Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  # Security Features - Admin check
  helper_method :signed_in_as_admin?
  def signed_in_as_admin?
    signed_in? && current_user.admin?
  end
  
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
  
  # Filters
  private
    before_filter :identify_controller_and_action
    
    def browser_required
      render :file => "#{RAILS_ROOT}/public/406.html", :status => 406 unless !params.key?(:format) || params[:format] == 'js'
    end

    def identify_controller_and_action
      @current_action = action_name
      @current_controller = controller_name
    end
    
    def web_service_authorization_required
      if !current_user
        render :file => "#{RAILS_ROOT}/public/401.html", :status => 401 if ['json','xml'].include?(params[:format]) 
      end
    end
end
