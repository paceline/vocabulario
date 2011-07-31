class TagsController < ApplicationController
  
  # Filters
  before_filter :browser_required
  
  # Tag vocabulary with new tag list
  def update
    @object = Object.const_get(params[:type]).find(params[:id])
    @object.tag_list = params[:tag_list]
    @object.save
    render :layout => false
  end
  
end
