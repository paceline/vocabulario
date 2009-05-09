class VocabulariesController < ApplicationController
  # Layout
  layout 'default'
  
  # Filters
  before_filter :login_required, :except => [:index, :refresh_language, :select, :show, :tags_for_language]
  before_filter :admin_required, :only => [:apply_tags, :create, :destroy, :edit, :import, :new, :unlink]
  
  # Features
  in_place_edit_for :vocabulary, :word
  in_place_edit_for :vocabulary, :gender
  in_place_edit_for :vocabulary, :language_id, { :method => :word }
  
  # Tag vocabulary with new tag list
  def apply_tags
    @vocabulary = Vocabulary.find(params[:id])
    @vocabulary.apply_tags_to_translations
    flash[:notice] = "#{@vocabulary.word}'s tags have been copied to all translations."
    redirect_to vocabularies_permalink_path(@vocabulary.permalink)
  end
  
  # Create translation or new vocabulary
  def create
    if params[:translation]
      copy_tags = params[:vocabulary].delete(:copy_tags)
      @translation = Vocabulary.find(params[:translation][:vocabulary2_id])
      @vocabulary = Vocabulary.find_by_word(params[:vocabulary][:word])
      @vocabulary = current_user.vocabularies.build(params[:vocabulary]) unless @vocabulary
      @vocabulary.tag_list = (@vocabulary.tag_list + @translation.tag_list).uniq if copy_tags
      @translation.translation_to << @vocabulary
      flash[:notice] = "Translation has been successfully saved."
      redirect_to vocabularies_permalink_path(@translation.permalink)
    else
      params[:vocabulary].delete(:gender) if params[:vocabulary][:gender].blank?
      type = params[:vocabulary][:type] ? params[:vocabulary].delete(:type) : 'Vocabulary'
      @vocabulary = current_user.send(type.pluralize.downcase).build(params[:vocabulary])
      success = @vocabulary && @vocabulary.valid?
      if success && @vocabulary.errors.empty?
        @vocabulary.save
        @translation = @vocabulary
        flash[:notice] = "\"#{@vocabulary.word}\" has been added to the database."
        redirect_to edit_vocabulary_path(@translation)
      else
        render :action => 'new'
      end
    end
  end
  
  # Add translation form
  def edit
    @translation = Vocabulary.find(params[:id])
  end
  
  # Delete vocabulary, including translation links
  def destroy
    @vocabulary = Vocabulary.find(params[:id])
    @vocabulary.destroy
    flash[:notice] = "Vocabulary has been deleted from to the database."
    redirect_to vocabularies_path
  end
  
  # Display paged list of vocabularies (html) / javascript array of vocabularies for input field suggestions (js)
  def index
    @vocabularies_list = params[:language] ? Vocabulary.find(:all, :order => 'word', :conditions => ['language_id != ?',params[:language]]) : Vocabulary.find(:all, :order => 'word')
    @vocabularies = @vocabularies_list.paginate :page => params[:page], :per_page => 100
    respond_to do |format|
      format.html { render :action => 'index' }
      format.js {
        render :update do |page|
          page << "var vocabularies = new Array('" + @vocabularies_list.collect { |v| v.word }.join("','") + "');"
        end
      }
    end
  end
  
  # Import CSV file using FasterCSV (very buggy)
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
  
  # Make sure that language matches text entered on edit page
  def refresh_language
    @vocabulary = Vocabulary.find_by_word(params[:word])
    if @vocabulary
      @language = @vocabulary.language
      render :update do |page|
        page << "$('vocabulary_language_id').selectedIndex = #{Language.list.index(@language)}"
      end
    else
      render :nothing => true
    end
  end
  
  # /scores/new support: Make sure to and from select boxes always have different selected languages
  def select
    @languages = Language.list("id != #{params[:language_id]}")
    @selected = params[:language_id] == params[:selected] ? @languages.first.id : params[:selected].to_i
    render :layout => false
  end
  
  # Display vocabulary attributes
  def show
    begin
      @vocabulary = Vocabulary.find_by_permalink(params[:permalink])
      @language = @vocabulary.language
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    end
  end
  
  # Tag vocabulary with new tag list
  def tag
    vocabulary = Vocabulary.find(params[:id])
    vocabulary.tag_list = params[:tag_list]
    vocabulary.save
    render :partial => "shared/taglist_detail", :object => vocabulary
  end
  
  # /scores/new support: Update tags select box based on seleted language 
  def tags_for_language
    language = Vocabulary.find(params[:language_id])
    @tags = language.tags_for_language
    render :layout => false
  end
  
  # Remove translation object corresponding to two vocabularies
  def unlink
    Translation.delete_all(['(vocabulary1_id = ? AND vocabulary2_id = ?) OR (vocabulary1_id = ? AND vocabulary2_id = ?)', params[:id], params[:link], params[:link], params[:id]])
    render :update do |page|
      page.remove "translation_#{params[:link]}"
      page.visual_effect :highlight, 'translations'
    end
  end
  
end
