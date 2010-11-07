class SearchController < ApplicationController

  # Filters
  before_filter :browser_required, :only => [:live]
  
  # Live search of the vocabularies database
  def live
    @search = params[:word]
    if @search.blank?
      @page = 1
      @vocabularies = Vocabulary.paginate :all, :order => 'word', :page => params[:page], :per_page => Vocabulary.per_page
    else
      @page = 0
      @vocabularies = Vocabulary.find :all, :conditions => ['word LIKE ?',"%#{@search}%"], :order => 'word'
    end
    @vocabularies.blank? ? render(:nothing => true) : render(:partial => 'vocabularies/vocabularies', :object => @vocabularies, :locals => {:page => @page})
  end
  
  # Display paged list of vocabularies with correspoding language
  #
  # API information - 
  #   /vocabularies/by_language/#{id|permalink}.xml|json (No oauth required)
  def by_language
    @language = Vocabulary.find_by_id_or_permalink(params[:id])
    @vocabularies_list = @language.vocabularies
    respond
  end
  
  # Display paged list of vocabularies with correspoding tag
  #
  # API information - 
  #   /vocabularies/by_tag/#{permalink}.xml|json (No oauth required)
  def by_tag
    if params[:id] == 'untagged'
      @tag = 'Untagged'
      @vocabularies_list = Vocabulary.find :all, :joins => 'LEFT JOIN taggings ON taggings.taggable_id = vocabularies.id', :group => 'vocabularies.id', :having => 'COUNT(taggings.id) = 0', :order => 'word'
    else
      @tag = Tag.find_by_id_or_permalink(params[:id])
      @vocabularies_list = Vocabulary.find :all, :conditions => ['taggings.tag_id = ?', @tag.id], :include => [ :taggings ], :order => 'word'
    end
    respond
  end
  
  # Display paged list of vocabularies with correspoding tag
  #
  # API information - 
  #   /vocabularies/by_type/#{type}.xml|json (No oauth required)
  def by_type
    conditions = params[:id] == "other" ? "type IS NULL" : "type = '#{params[:id]}'"
    @vocabularies_list = Vocabulary.find :all, :conditions => conditions, :order => 'word'
    respond
  end
  
  # Display paged list of vocabularies with correspoding tag
  #
  # API information - 
  #   /vocabularies/by_user/#{id|permalink}.xml|json (No oauth required)
  def by_user
    @user = User.find_by_id_or_permalink(params[:id])
    @vocabularies_list = Vocabulary.find_by_user_id @user.id, :order => 'word'
    respond
  end
  
  
  private
    
    # Render is identical for all actions
    def respond
      if @vocabularies_list.blank?
        file_not_found
      else
        respond_to do |format|
          format.html {
            @vocabularies = @vocabularies_list.paginate :page => params[:page], :per_page => Vocabulary.per_page
            @page = params[:page] || 1
            render 'vocabularies/index'
          }
          format.js {
            @last = params[:last].to_i
            @vocabularies = @vocabularies_list.paginate :page => @last + 1, :per_page => Vocabulary.per_page     
            @page = @last + 1
            @vocabularies.empty? ? render(:nothing => true) : render(:partial => 'vocabularies/vocabularies', :object => @vocabularies, :locals => {:page => @page})
          }
          format.json { render :json => @vocabularies.to_json(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
          format.xml { render :xml => @vocabularies.to_xml(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
        end
      end
    end
end
