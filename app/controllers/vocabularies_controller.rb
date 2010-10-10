class VocabulariesController < ApplicationController
  
  # Filters
  before_filter :browser_required, :except => [:conjugate, :index, :show, :translate]
  before_filter :login_required, :except => [:conjugate, :index, :refresh_language, :select, :show, :translate]
  before_filter :admin_required, :only => [:destroy]
  
  # Features
  in_place_edit_for :vocabulary, :word
  in_place_edit_for :vocabulary, :gender
  in_place_edit_for :vocabulary, :language_id, { :method => :word }
  in_place_edit_for :vocabulary, :class_type
  
  # Link vocabulary to a new conjugation
  def apply_conjugation
    @vocabulary = Vocabulary.find params[:id]
    @vocabulary.update_pattern_links params[:conjugation_time_id], params[:conjugations].values
    respond_to do |format|
      format.js {
        render :update do |page|
          page << "['#{params[:conjugations].keys.join('\',\'')}'].collect(function(n) { Effect.Puff('unsaved_' + n); })"
        end
      }
    end
  end
  
  # Tag vocabulary with new tag list
  def apply_tags
    @vocabulary = Vocabulary.find(params[:id])
    @vocabulary.apply_tags_to_translations
    flash.now[:success] = "#{@vocabulary.word}'s tags have been copied to all translations."
    render :partial => 'layouts/flashes'
  end
  
  # Apply vocabulary's type to all translations
  def apply_type
    @vocabulary = Vocabulary.find(params[:id])
    @vocabulary.apply_type_to_translations
    flash.now[:success] = "#{@vocabulary.word}'s type has been copied to all translations."
    render :partial => 'layouts/flashes'
  end
  
  # Conjugate verb
  #
  # API information - 
  #   /vocabularies/#{id|permalink}/translate.xml|json (No Oauth required)
  #   Required parameter: tense_id
  def conjugate
    begin
      @vocabulary = Verb.find_by_id_or_permalink params[:id]
      @vocabulary.conjugate_all params[:tense_id].to_i
      respond_to do |format|
        format.json { render :json => { :conjugation => @vocabulary.conjugation_to_hash.to_json } }
        format.xml { render :xml => @vocabulary.conjugation_to_hash.to_xml(:root => 'conjugation') }
      end
    rescue ActiveRecord::RecordNotFound
      file_not_found
    rescue RuntimeError
      invalid_request
    end
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
    @translation = Vocabulary.find_by_id_or_permalink(params[:id])
  end
  
  # Delete vocabulary, including translation links
  def destroy
    @vocabulary = Vocabulary.find(params[:id])
    @vocabulary.destroy
    flash[:notice] = "You wanted it. Vocabulary has been deleted from to the database."
    render :nothing => true
  end
  
  # Display paged list of vocabularies (html) / javascript array of vocabularies for input field suggestions (js)
  #
  # API information - 
  #   /vocabularies.xml|json (No Oauth required)
  def index
    @vocabularies_list = params[:language] ? Vocabulary.find(:all, :order => 'word', :conditions => ['language_id != ?',params[:language]]) : Vocabulary.find(:all, :order => 'word')
    @vocabularies = @vocabularies_list.paginate :page => params[:page], :per_page => 150
    respond_to do |format|
      format.html { render :action => 'index' }
      format.js {
        if params[:menu]
          render :partial => "index_tab_#{params[:menu]}"
        else
          render :text => "var vocabularies = ['" + @vocabularies_list.collect { |v| v.word }.join("','") + "'];"
        end
      }
      format.json { render :json => @vocabularies_list.to_json(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
      format.xml { render :xml => @vocabularies_list.to_xml(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
    end
  end
  
  # Import pre-parsed CSV data
  def import
    if request.post?
      begin
        raise ArgumentError unless params.key?(:data) && params.key?(:languages)
        languages = []
        0.upto(params[:languages].size-1) { |i| languages << Language.find(params[:languages][i.to_s.to_sym]) }
        params[:data].each_value do |row|
          type = row.delete_at(0)
          vocabularies = []
          0.upto(row.size-1) do |i|
            vocabulary = Object.const_get(type.blank? ? "Vocabulary" : type).find_or_initialize_by_word(row[i]) { |v| v.language = languages[i] }
            vocabulary.import(current_user, (params[:vocabulary].key?(:tags) ? params[:vocabulary][:tags] : nil), params[:vocabulary][:new_tags])
            vocabulary.translation_to << vocabularies.first unless vocabularies.blank?
            vocabulary.save
            vocabularies << vocabulary
          end
        end
        flash.now[:success] = "Seems like the import worked just fine."
      rescue
        flash.now[:failure] = "Didn't work. Please check your format and try again."
      end
      render :partial => 'layouts/flashes'
    else
      render 'import'
    end
  end
  
  # Generates preview when importing vocabularies
  def preview
    begin
      raise ArgumentError if params[:csv].blank? || (params[:csv].count(';') == 0 && params[:csv].count(',') == 0)
      @data = []
      @max_elements = 0
      @languages = Language.list
      sep = params[:csv].count(';') > params[:csv].count(',') ? ';' : ','
      FasterCSV.parse(params[:csv], { :col_sep => sep, :row_sep => :auto }) do |row|
        @data << row
        @max_elements = row.size if row.size > @max_elements
      end
      render :update do |page|
        page.replace_html 'preview', render(:partial => 'preview')
        page.hide 'vocabulary_csv'
      end
    rescue Exception => @exception
      render :nothing => true
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
  
  # Display vocabulary attributes
  #
  # API information - 
  #   /vocabularies/#{id|permalink}.xml|json (No Oauth required)
  def show
    begin
      @vocabulary = Vocabulary.find_by_id_or_permalink(params.key?(:vocabulary_id) ? params[:vocabulary_id] : params[:id])
      @language = @vocabulary.language
      if @vocabulary.verb?
        @conjugations = params.key?(:conjugation_time_id) ? @vocabulary.patterns.for_tense(params[:conjugation_time_id]) : @vocabulary.patterns
      end
      respond_to do |format|
        format.html
        format.js {
          if params.key?(:conjugation_time_id)
            @patterns = @vocabulary.auto_detect_patterns params[:conjugation_time_id]
            @pronouns = @vocabulary.language.personal_pronouns
            render :partial => 'assign_conjugation'
          else
            render :partial => "show_tab_#{params[:menu]}"
          end
        }
        format.json { render :json => @vocabulary.to_json(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
        format.xml { render :xml => @vocabulary.to_xml(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
      end
    rescue ActiveRecord::RecordNotFound
      file_not_found
    end
  end
  
  # Tag vocabulary with new tag list
  def tag
    vocabulary = Vocabulary.find(params[:id])
    vocabulary.tag_list = params[:tag_list]
    vocabulary.save
    render :partial => "shared/taglist_detail", :object => vocabulary.tag_list
  end
  
  # Translate vocabulary
  #
  # API information - 
  #   /vocabularies/#{id|permalink}/translate.xml|json (No Oauth required)
  #   Optional parameter: language_id
  def translate
    begin
      @vocabulary = Vocabulary.find_by_id_or_permalink(params.key?(:vocabulary_id) ? params[:vocabulary_id] : params[:id])
      language_id = params.key?(:language_id) ? params[:language_id].to_i : nil
      respond_to do |format|
        format.json { render :json => @vocabulary.translations(language_id).to_json(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } })  }
        format.xml { render :xml => @vocabulary.translations(language_id).to_xml(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
      end
    rescue ActiveRecord::RecordNotFound
      file_not_found
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