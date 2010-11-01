class WikiPagesController < ApplicationController
  
  # Import irwi features
  acts_as_wiki_pages_controller
  
  # Override access control (editing, deleting)
  def edit_allowed?
    if (@page.new_record? || @page.public) && !@page.path.blank?
      current_user != nil
    else
      current_user && @page.creator_id == current_user.id
    end
  end
  
  # Override access control (viewing)
  def show_allowed?
    if @page.public
      true
    else
      current_user && @page.creator_id == current_user.id
    end
  end
  
  # Override access control (history)
  def history_allowed?
    show_allowed?
  end
  
  # Find pages by tag
  def by_tag
    @pages = WikiPage.find_tagged_with params[:id], :order => "name"
  end
  
end