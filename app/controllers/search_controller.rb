class SearchController < ApplicationController
  # Layout
  layout 'default', :except => [:live]
  
  # Live search of the vocabularies database
  def live
    @search = params[:word]
    if @search.blank?
      @vocabularies = Vocabulary.paginate :all, :page => params[:page], :order => 'word'
    else
      @vocabularies = Vocabulary.find(:all, :conditions => ['word LIKE ?',"%#{params[:word]}%"], :limit => 100, :order => 'word')
      render :nothing => true if @vocabularies.blank?
    end
  end
  
  # Display paged list of vocabularies with correspoding language
  def by_language
    @language = Vocabulary.find_by_permalink(params[:id])
    @vocabularies = Vocabulary.paginate_by_language_id @language.id, :page => params[:page], :order => 'word'
    render 'vocabularies/index'
  end
  
  # Display paged list of vocabularies with correspoding tag
  def by_tag
    @tag = Tag.find_by_permalink(params[:id])
    @vocabularies = Vocabulary.paginate :all, :conditions => ['taggings.tag_id = ?', @tag.id], :include => [ :taggings ], :page => params[:page], :order => 'word'
    render 'vocabularies/index'
  end
  
end
