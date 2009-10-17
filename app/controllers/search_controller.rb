class SearchController < ApplicationController

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
  def by_language
    begin
      @language = Vocabulary.find_by_permalink(params[:id])
      @vocabularies = Vocabulary.paginate_by_language_id @language.id, :page => params[:page], :order => 'word'
      render 'vocabularies/index'
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    end
  end
  
  # Display paged list of vocabularies with correspoding tag
  def by_tag
    begin
      if params[:id] == 'untagged'
        @tag = 'Untagged'
        @vocabularies = Vocabulary.paginate :all, :joins => 'LEFT JOIN taggings ON taggings.taggable_id = vocabularies.id', :group => 'vocabularies.id', :having => 'COUNT(taggings.id) = 0', :page => params[:page], :order => 'word'
      else
        @tag = Tag.find_by_permalink(params[:id])
        @vocabularies = Vocabulary.paginate :all, :conditions => ['taggings.tag_id = ?', @tag.id], :include => [ :taggings ], :page => params[:page], :order => 'word'
      end
      render 'vocabularies/index'
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    end
  end
  
  # Display paged list of vocabularies with correspoding tag
  def by_type
    begin
      conditions = params[:id] == "other" ? "type IS NULL" : "type = '#{params[:id]}'"
      @vocabularies = Vocabulary.paginate :all, :conditions => conditions, :page => params[:page], :order => 'word'
      render 'vocabularies/index'
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    end
  end
  
  # Display paged list of vocabularies with correspoding tag
  def by_user
    begin
      @user = User.find_by_permalink(params[:id])
      @vocabularies = Vocabulary.paginate_by_user_id @user.id, :page => params[:page], :order => 'word'
      render 'vocabularies/index'
      rescue
        render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
      end
  end
  
end
