class WikiPagesController < ApplicationController

  # Import irwi features
  acts_as_wiki_pages_controller

  # Override access control (editing, deleting)
  def edit_allowed?
    if (@page.new_record? || @page.public) && @page.id != 1
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
    @pages = WikiPage.find_tagged_with Tag.find_by_permalink(params[:id]).name, :order => "name"
  end
  
  # Insert prefix before path
  def prefix
    unless params[:language_id].blank?
      language = Language.find(params[:language_id])
      prefix = (language.translations.all(language.id).first || language).permalink
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          page << "appendOrReplace('path', '#{prefix ? prefix : ""}', '-')"
        end
      }
    end
  end

end
