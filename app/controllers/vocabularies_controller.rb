class VocabulariesController < ApplicationController
  layout 'default'
  
  before_filter :login_required, :except => [:index]
  
  in_place_edit_for :vocabulary, :word
  in_place_edit_for :vocabulary, :gender
  in_place_edit_for :vocabulary, :language_id, { :method => :word }
  
  def create
    if params[:translation]
      @translation = Vocabulary.find(params[:translation][:vocabulary2_id])
      @vocabulary = current_user.vocabularies.build(params[:vocabulary])
      @translation.translation_to << @vocabulary
      flash[:notice] = "\"#{@vocabulary.word}\" has been added to the database."
      redirect_to @vocabulary
    else
      params[:vocabulary].delete(:gender) if params[:vocabulary][:gender].blank?
      @translation = current_user.vocabularies.build(params[:vocabulary])
      @translation.save
      flash[:notice] = "\"#{@translation.word}\" has been added to the database."
      redirect_to edit_vocabulary_path(@translation)
    end
  end
  
  def edit
    @translation = Vocabulary.find(params[:id])
  end
  
  def destroy
    @vocabulary = Vocabulary.find(params[:id])
    @vocabulary.destroy
    flash[:notice] = "Vocabulary has been deleted from to the database."
    redirect_to vocabularies_path
  end
  
  def new
  end
  
  def index
    @vocabularies = Vocabulary.paginate :all, :page => params[:page], :order => 'word'
  end
  
  def import
    if request.post?
      tags = params[:vocabulary][:tags].join(',')
      FasterCSV.parse(params[:vocabulary][:file].read, { :col_sep => ';', :row_sep => :auto }) do |row|
        if @from && @to
          begin
            vocabulary = @from.vocabularies.new({ :user_id => current_user })
            vocabulary.import(row[0], tags)
            vocabulary.save
            row[1..row.size-1].each do |translations|
              if translations
                translation = @to.vocabularies.new({ :user_id => current_user })
                translation.import(translations, tags)
                vocabulary.translation_to << translation
              end
            end
          rescue
          end
        else
          @from = Vocabulary.find_by_word(row[0].split(' ').first)
          @to = Vocabulary.find_by_word(row[1].split(' ').first)
        end
      end
      flash[:notice] = "Vocabularies have been imported to the database."
    end
  end
  
  def show
    @vocabulary = Vocabulary.find(params[:id])
    @language = @vocabulary.language
  end
  
  def tag
    vocabulary = Vocabulary.find(params[:id])
    vocabulary.tag_list = params[:tag_list]
    vocabulary.save
    render :partial => "shared/taglist_detail", :object => vocabulary
  end
  
  def by_language
    @language = Vocabulary.find_by_permalink(params[:id])
    @vocabularies = Vocabulary.paginate_by_language_id @language.id, :page => params[:page], :order => 'word'
    render :action => 'index'
  end
  
  def by_tag
    @tag = Tag.find_by_permalink(params[:id])
    @vocabularies = Vocabulary.paginate :all, :conditions => ['taggings.tag_id = ?', @tag.id], :include => [ :taggings ], :page => params[:page], :order => 'word'
    render :action => 'index'
  end

end
