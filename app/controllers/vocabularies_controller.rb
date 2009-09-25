class VocabulariesController < ApplicationController
  
  # Filters
  before_filter :users_only, :except => [:index, :refresh_language, :select, :show, :tags_for_language]
  before_filter :admin_only, :only => [:apply_conjugation, :apply_tags, :apply_type, :create, :destroy, :edit, :import, :new, :unapply_conjugation, :unlink]
  
  # Features
  in_place_edit_for :vocabulary, :word
  in_place_edit_for :vocabulary, :gender
  in_place_edit_for :vocabulary, :language_id, { :method => :word }
  in_place_edit_for :vocabulary, :class_type
  in_place_edit_for :vocabulary, :comment
  
  # Link vocabulary to a new conjugation
  def apply_conjugation
    @vocabulary = Vocabulary.find(params[:id])
    conjugation = Conjugation.find(params[:conjugation_id])
    @vocabulary.conjugations << conjugation if conjugation
    @conjugations = @vocabulary.conjugations
    render :update do |page|
      page.show 'transformations'
      page.replace_html 'conjugations', :partial => 'conjugation_menu'
      page.visual_effect :highlight, "conjugation_#{params[:conjugation_id]}"
    end
  end
  
  # Tag vocabulary with new tag list
  def apply_tags
    @vocabulary = Vocabulary.find(params[:id])
    @vocabulary.apply_tags_to_translations
    flash[:success] = "#{@vocabulary.word}'s tags have been copied to all translations."
    redirect_to vocabulary_path(@vocabulary.permalink)
  end
  
  # Apply vocabulary's type to all translations
  def apply_type
    @vocabulary = Vocabulary.find(params[:id])
    @vocabulary.apply_type_to_translations
    flash[:success] = "#{@vocabulary.word}'s type has been copied to all translations."
    redirect_to vocabulary_path(@vocabulary.permalink)
  end
  
  # Create translation or new vocabulary
  def create
    if params[:translation]
      copy_tags = params[:vocabulary].delete(:copy_tags)
      @translation = Vocabulary.find(params[:translation][:vocabulary2_id])
      @vocabulary = Vocabulary.find_by_word(params[:vocabulary][:word])
      @vocabulary = Object.const_get(@translation.class.to_s).new(params[:vocabulary]) unless @vocabulary
      @vocabulary.user = current_user
      @vocabulary.tag_list = (@vocabulary.tag_list + @translation.tag_list).uniq if copy_tags
      @translation.translation_to << @vocabulary
      flash[:success] = "Translation has been successfully saved."
      redirect_to vocabulary_path(@translation.permalink)
    else
      params[:vocabulary].delete(:gender) if params[:vocabulary][:gender].blank?
      type = params[:vocabulary][:type].blank? ? 'Vocabulary' : params[:vocabulary].delete(:type)
      @vocabulary = Object.const_get(type).new(params[:vocabulary])
      if @vocabulary.valid? && @vocabulary.errors.empty?
        @vocabulary.user = current_user
        @vocabulary.save
        flash[:success] = "\"#{@vocabulary.word}\" has been added to the database."
        redirect_to vocabulary_path(@vocabulary.permalink)
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
    flash[:notice] = "You wanted it. Vocabulary has been deleted from to the database."
    redirect_to vocabularies_path
  end
  
  # Display paged list of vocabularies (html) / javascript array of vocabularies for input field suggestions (js)
  def index
    @vocabularies_list = params[:language] ? Vocabulary.find(:all, :order => 'word', :conditions => ['language_id != ?',params[:language]]) : Vocabulary.find(:all, :order => 'word')
    @vocabularies = @vocabularies_list.paginate :page => params[:page], :per_page => 150
    respond_to do |format|
      format.html { render :action => 'index' }
      format.js {
        render :update do |page|
          if params[:menu]
            page.hide 'browser'
            page << "['live_search','by_language','by_tag','by_type'].collect(function(v) { $(v + '_link').className = 'tab_link'; })"
            page << "$('#{params[:menu]}_link').addClassName('active')"
            page.replace_html 'browser', render(:partial => params[:menu])
            page << "new Effect.BlindDown('browser')"
          else
            page << "var vocabularies = new Array('" + @vocabularies_list.collect { |v| v.word }.join("','") + "');"
          end
        end
      }
      format.json { render :json => @vocabularies_list.to_json(:except => [ :user_id, :language_id, :permalink, :created_at, :updated_at ], :include => [ :language, :translation_to ]) }
      format.xml { render :xml => @vocabularies_list.to_xml(:except => [ :user_id, :language_id, :permalink, :created_at, :updated_at ], :include => [ :language, :translation_to ]) }
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
      flash[:success] = "Vocabularies have been imported to the database."
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
      @vocabulary = Vocabulary.find_by_permalink(params[:id])
      @language = @vocabulary.language
      @conjugations = @vocabulary.conjugations if @vocabulary.class == Verb
      @transformations = @vocabulary.transformations if @vocabulary.class == Verb
      @transformation = Transformation.new if @vocabulary.class == Verb
      if params[:menu]
        @display_transformations = @conjugations.empty? ? "display: none;" : "display: visible;" if @vocabulary.class == Verb
        render :update do |page|
          page << "['overview','conjugations','translations'].collect(function(v) { $(v + '_link').className = 'tab_link'; })"
          page << "$('#{params[:menu]}_link').addClassName('active')"
          page.replace_html 'vocabulary_pane', render(:partial => params[:menu])
        end
      end
    rescue
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    end
  end
  
  # Tag vocabulary with new tag list
  def tag
    vocabulary = Vocabulary.find(params[:id])
    vocabulary.tag_list = params[:tag_list]
    vocabulary.save
    render :partial => "shared/taglist_detail", :object => vocabulary.tag_list
  end
  
  # /scores/new support: Update tags select box based on seleted language 
  def tags_for_language
    language = Vocabulary.find(params[:language_id]) if params[:language_id]
    language = ConjugationTime.find(params[:conjugation_time_id]).language if params[:conjugation_time_id]
    @tags = language.tags_for_language
    render :layout => false
  end
  
  # Remove conjugation from vocabulary
  def unapply_conjugation
    @vocabulary = Vocabulary.find(params[:id])
    conjugation = Conjugation.find(params[:conjugation_id])
    @vocabulary.conjugations.delete(conjugation) if conjugation
    @conjugations = @vocabulary.conjugations
    render :update do |page|
      page.remove "conjugation_#{params[:conjugation_id]}"
      page.visual_effect :highlight, 'conjugations'
    end
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
