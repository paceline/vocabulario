class SearchController < ApplicationController

  # Filters
  before_filter :browser_required, :only => [:live]
  
  # Live search of the vocabularies database
  def live
    @search = params[:word]
    if @search.blank?
      @vocabularies = Vocabulary.paginate :all, :page => params[:page], :order => 'word'
    else
      @vocabularies = Vocabulary.find(:all, :conditions => ['word LIKE ?',"%#{@search}%"], :limit => 100, :order => 'word')
      render :nothing => true if @vocabularies.blank?
    end
  end
  
  # Display paged list of vocabularies with correspoding language
  #
  # API information - 
  #   /vocabularies/by_language/#{id|permalink}.xml|json (No oauth required)
  def by_language
    begin
      @language = Vocabulary.find_by_id_or_permalink(params[:id])
      @vocabularies = Vocabulary.paginate_by_language_id @language.id, :page => params[:page], :order => 'word'
      respond
    rescue ActiveRecord::RecordNotFound
      file_not_found
    end
  end
  
  # Display paged list of vocabularies with correspoding tag
  #
  # API information - 
  #   /vocabularies/by_tag/#{permalink}.xml|json (No oauth required)
  def by_tag
    begin
      if params[:id] == 'untagged'
        @tag = 'Untagged'
        @vocabularies = Vocabulary.paginate :all, :joins => 'LEFT JOIN taggings ON taggings.taggable_id = vocabularies.id', :group => 'vocabularies.id', :having => 'COUNT(taggings.id) = 0', :page => params[:page], :order => 'word'
      else
        @tag = Tag.find_by_id_or_permalink(params[:id])
        @vocabularies = Vocabulary.paginate :all, :conditions => ['taggings.tag_id = ?', @tag.id], :include => [ :taggings ], :page => params[:page], :order => 'word'
      end
      respond
    rescue ActiveRecord::RecordNotFound
      file_not_found
    end
  end
  
  # Display paged list of vocabularies with correspoding tag
  #
  # API information - 
  #   /vocabularies/by_type/#{type}.xml|json (No oauth required)
  def by_type
    begin
      conditions = params[:id] == "other" ? "type IS NULL" : "type = '#{params[:id]}'"
      @vocabularies = Vocabulary.paginate :all, :conditions => conditions, :page => params[:page], :order => 'word'
      respond
    rescue ActiveRecord::RecordNotFound
      file_not_found
    end
  end
  
  # Display paged list of vocabularies with correspoding tag
  #
  # API information - 
  #   /vocabularies/by_user/#{id|permalink}.xml|json (No oauth required)
  def by_user
    begin
      @user = User.find_by_id_or_permalink(params[:id])
      @vocabularies = Vocabulary.paginate_by_user_id @user.id, :page => params[:page], :order => 'word'
      respond
    rescue ActiveRecord::RecordNotFound
      file_not_found
    end
  end
  
  
  private
    
    # Render is identical for all actions
    def respond
      if @vocabularies.blank?
        file_not_found
      else
        respond_to do |format|
          format.html { render 'vocabularies/index' }
          format.json { render :json => @vocabularies.to_json(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
          format.xml { render :xml => @vocabularies.to_xml(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
        end
      end
    end
  
end
