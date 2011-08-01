class StatusController < ApplicationController
  
  # Filters
  before_filter :authorization_for_web_services_required
  
  # Gather status updates
  #
  # API information - 
  #   /status.xml|json or /timeline.xml|json (Oauth required)
  #   /users/#{id|permalink}/status.xml|json or /users/#{id|permalink}/timeline.xml|json (Oauth required)
  def index
    @timeline = params.key?(:since) ? Status.timeline(params[:user_id], Time.at(params[:since].to_f)) : Status.timeline(params[:user_id])
    @page = params.key?(:last) ? params[:last].to_i + 1 : (params.key?(:page) ? params[:page] : 1)
    @timeline_results = @timeline.paginate :page => @page, :per_page => 15
      respond_to do |format|
        format.html { redirect_to test_path if @timeline.blank? }
        format.atom { @timeline.first ? render(:layout => false) : render(:nothing => true) }
        format.js {
          if @timeline_results.empty?
            render(:nothing => true)
          else
            render :update do |page|
              page.insert_html :bottom, 'latest', render(:partial => 'timeline')
              page.replace_html 'pagination', will_paginate(@timeline_results)
            end
          end
        }
        format.json { render :json => @timeline }
        format.xml { render :xml => @timeline }
      end
  end
  
  # Gather status updates
  #
  # API information - 
  #   /status/user_timeline.xml|json (Oauth required)
  def user_timeline
    #begin
      @timeline = Status.timeline(current_user.id)
      respond_to do |format|
        format.json { render :json => @timeline }
        format.xml { render :xml => @timeline }
      end
    #rescue Exception
    #  internal_server_error
    #end
  end  
  
end
