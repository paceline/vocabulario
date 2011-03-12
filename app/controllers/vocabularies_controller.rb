class VocabulariesController < ApplicationController
  
  # Filters
  before_filter :browser_required, :except => [:conjugate, :index, :show, :translate, :by_language, :by_tag, :by_type, :by_user]
  before_filter :login_required, :except => [:conjugate, :index, :refresh_language, :select, :show, :translate, :by_language, :by_tag, :by_type, :by_user, :live]
  before_filter :admin_required, :only => [:destroy]
  
  # Link vocabulary to a new conjugation
  def apply_conjugation
    @vocabulary = Vocabulary.find params[:id]
    @vocabulary.update_pattern_links params[:tense_id], params[:conjugations].values
    respond_to do |format|
      format.js {
        render :update do |page|
          page << "['#{params[:conjugations].keys.join('\',\'')}'].collect(function(n) { Effect.Puff('unsaved_' + n); });"
        end
      }
    end
  end
  
  # Tag vocabulary with new tag list
  def apply_tags
    @vocabulary = Vocabulary.find_by_id_or_permalink params[:id]
    @vocabulary.apply_tags_to_translations
    flash.now[:success] = "#{@vocabulary.word}'s tags have been copied to all translations."
    render 'shared/notify'
  end
  
  # Apply vocabulary's type to all translations
  def apply_type
    @vocabulary = Vocabulary.find_by_id_or_permalink params[:id]
    @vocabulary.apply_type_to_translations
    flash.now[:success] = "#{@vocabulary.word}'s type has been copied to all translations."
    render 'shared/notify'
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
        format.json { render :json => @vocabulary.conjugation_to_hash.to_json }
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
    @page = params.key?(:last) ? params[:last].to_i + 1 : 1
    @vocabularies = @vocabularies_list.paginate :page => @page, :per_page => Vocabulary.per_page
    respond_to do |format|
      format.html
      format.js {
        if params[:menu]
          @menu = params[:menu]
          render :layout => false
        elsif params[:last]
          @vocabularies.empty? ? render(:nothing => true) : render(:partial => 'vocabularies', :object => @vocabularies, :locals => {:page => @page})
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
      respond_to do |format|
        format.js { render(:update) { |page| page.replace_html 'notice', render(:partial => 'layouts/flashes') } }
      end
    else
      render 'import'
    end
  end
  
  # Generates preview when importing vocabularies
  def preview
    begin
      require 'csv'
      raise ArgumentError if params[:csv].blank? || (params[:csv].count(';') == 0 && params[:csv].count(',') == 0)
      @data = []
      @max_elements = 0
      @languages = Language.list
      sep = params[:csv].count(';') > params[:csv].count(',') ? ';' : ','
      CSV.parse(params[:csv], { :col_sep => sep, :row_sep => :auto }) do |row|
        @data << row
        @max_elements = row.size if row.size > @max_elements
      end
      render :update do |page|
        page.replace_html 'preview', render(:partial => 'preview')
        page.hide 'vocabulary_csv'
      end
    rescue Exception => @exception
      raise @exception.inspect
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
        @conjugations = params.key?(:tense_id) ? @vocabulary.patterns.for_tense(params[:tense_id]) : @vocabulary.patterns
      end
      respond_to do |format|
        format.html
        format.js {
          if params.key?(:tense_id)
            @patterns = @vocabulary.auto_detect_patterns params[:tense_id]
            @pronouns = @vocabulary.language.personal_pronouns
          else
            @menu = params[:menu]
          end
          render :layout => false
        }
        format.json { render :json => @vocabulary.to_json(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
        format.xml { render :xml => @vocabulary.to_xml(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
      end
    rescue ActiveRecord::RecordNotFound
      file_not_found
    end
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
    vocabulary1 = Vocabulary.find_by_id_or_permalink(params[:id])
    vocabulary2 = Vocabulary.find_by_id_or_permalink(params[:link])
    Translation.delete_all(['(vocabulary1_id = ? AND vocabulary2_id = ?) OR (vocabulary1_id = ? AND vocabulary2_id = ?)', vocabulary1.id, vocabulary2.id, vocabulary2.id, vocabulary1.id])
    render :update do |page|
      page.remove "translation_#{vocabulary2.id}"
      page.visual_effect :highlight, 'translations'
    end
  end
  
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