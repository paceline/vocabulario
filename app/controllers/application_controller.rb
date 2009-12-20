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
  
  # Security Features - Admin check
  helper_method :signed_in_as_admin?
  
  # Ensure compatability with OAuth
  def authorized?
    true
  end
  
  # Ensure compatability with OAuth
  def current_user
    @current_user ||= user_from_cookie
  end
  
  def signed_in_as_admin?
    signed_in? && current_user.admin?
  end
  
  def login_required
    deny_access("Please Login or Create an Account to Access that Feature.") unless signed_in?
  end

  def admin_only
    deny_access("Please Login as an administrator to Access that Feature.") unless signed_in_as_admin?
  end

  # Security Features - Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  # Filters
  private
    before_filter :identify_controller_and_action

    def identify_controller_and_action
      @current_action = action_name
      @current_controller = controller_name
    end
end
