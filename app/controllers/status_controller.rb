class StatusController < ApplicationController
  
  # Filters
  before_filter :web_service_authorization_required
  
  # Gather status updates
  #
  # API information - 
  #   /status.xml|json or /timline.xml|json (Oauth required)
  #   /users/#{id|permalink}/status.xml|json or /users/#{id|permalink}/timeline.xml|json (Oauth required)
  def index
    @timeline = params.key?(:since) ? Status.timeline(params[:user_id], Time.at(params[:since].to_f)) : Status.timeline(params[:user_id])
    respond_to do |format|
      format.html
      format.atom { @timeline.first ? render(:layout => false) : render(:nothing => true) }
      format.json { render :json => @timeline }
      format.xml { render :xml => @timeline }
    end
  end
  
end