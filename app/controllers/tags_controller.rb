class TagsController < ApplicationController
  
  # Tag vocabulary with new tag list
  def update
    object = Object.const_get(params[:type]).find(params[:id])
    object.tag_list = params[:tag_list]
    object.save
    render :partial => "shared/taglist_detail", :object => object
  end
  
end
