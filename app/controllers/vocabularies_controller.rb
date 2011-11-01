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
    flash.now[:notice] = "#{@vocabulary.word}'s tags have been copied to all translations."
    render 'shared/notify'
  end
  
  # Apply vocabulary's type to all translations
  def apply_type
    @vocabulary = Vocabulary.find_by_id_or_permalink params[:id]
    @vocabulary.apply_type_to_translations
    flash.now[:notice] = "#{@vocabulary.word}'s type has been copied to all translations."
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
  
  # Render new vocabulary form
  def new
    @vocabulary = Vocabulary.new(:user => current_user)
  end
  
  # Create translation or new vocabulary
  def create
    if params[:translation]
      @vocabulary = Vocabulary.find(params[:translation][:vocabulary2_id])
      translation = Object.const_get(@vocabulary.language? ? 'Noun' : @vocabulary.class.to_s).import(params[:vocabulary][:word], params[:vocabulary][:language_id], current_user, @vocabulary.tag_list)
      @vocabulary.translation_to << translation
      render 'create', :layout => false
    else
      params[:vocabulary].delete(:gender) if params[:vocabulary][:gender].blank?
      type = params[:vocabulary][:type].blank? ? 'Vocabulary' : params[:vocabulary].delete(:type)
      @vocabulary = Object.const_get(type).import(params[:vocabulary][:word], params[:vocabulary][:language_id], current_user)
      flash[:notice] = "\"#{@vocabulary.word}\" has been added to the database (if it didn't already exist)"
      redirect_to vocabulary_path(@vocabulary.permalink)
    end
  end
  
  # Delete vocabulary, including translation links
  def destroy
    @vocabulary = Vocabulary.find_by_permalink(params[:id])
    @vocabulary.destroy
    flash[:notice] = "You wanted it. Vocabulary has been deleted from to the database."
    redirect_to vocabularies_path
  end
  
  # Display paged list of vocabularies (html) / javascript array of vocabularies for input field suggestions (js)
  #
  # API information - 
  #   /vocabularies.xml|json (No Oauth required)
  def index
    @vocabularies_list = params[:language] ? Vocabulary.where(['language_id != ?',params[:language]]) : Vocabulary.all
    @page = params.key?(:last) ? params[:last].to_i + 1 : (params.key?(:page) ? params[:page] : 1)
    @vocabularies = @vocabularies_list.paginate :page => @page, :per_page => Vocabulary.per_page
    respond_to do |format|
      format.html
      format.js {
        if params[:last]
          if @vocabularies.empty?
            render(:nothing => true)
          else
            render :update do |page|
              page.insert_html :bottom, 'vocabulary_results', render(:partial => 'vocabularies', :object => @vocabularies, :locals => {:page => @page})
              page.replace_html 'pagination', will_paginate(@vocabularies)
            end
          end
        else
          @menu = params[:menu]
          render :update do |page|
            page.replace_html 'tab_browser', render(:partial => "index_tab_#{@menu}")
          end
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
          0.upto(row.size-1) do |j|
            vocabulary = Object.const_get(type.blank? ? "Vocabulary" : type).import(row[j], languages[j], current_user, (params[:vocabulary].key?(:tags) ? params[:vocabulary][:tags] : nil), params[:vocabulary][:new_tags])
            vocabulary.translation_to << vocabularies.first unless vocabularies.blank?
            vocabularies << vocabulary
          end
        end
        flash.now[:notice] = "Seems like the import worked just fine."
      rescue
        flash.now[:alert] = "Didn't work. Please check your format and try again."
      end
      respond_to do |format|
        format.js {
          render :update do |page|
            page.replace_html 'notice', render(:partial => 'layouts/flashes')
            page << "enableCsvObserver();"
            page << "$('import').setAttribute('disabled','disabled');"
          end
        }
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
        page << "$('import').removeAttribute('disabled');"
      end
    rescue Exception => @exception
      raise @exception.inspect
      render :nothing => true
    end
  end
  
  # Set language hidden field in translate form
  def set_language
    @language = Language.find_by_permalink(params[:id])
    @vocabularies = Object.const_get(params[:type]).where(['language_id = ?',@language.id]).order('vocabularies.word')
    render :layout => false
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
            if @menu == '2'
              @translation = Object.const_get(@vocabulary.class.to_s).new
              @languages = Language.list(['id != ?', @vocabulary.language.id])
              @language = @languages.first
            end
          end
          render :layout => false
        }
        format.json { render :json => @vocabulary.to_json(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }, :methods => :kind) }
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
        format.json { render :json => @vocabulary.translations.all(language_id).to_json(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } })  }
        format.xml { render :xml => @vocabulary.translations.all(language_id).to_xml(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
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
    if params[:word].blank?
      @page = 1
      @vocabularies_list = Vocabulary.all
      @vocabularies = @vocabularies_list.paginate :page => params[:page], :per_page => Vocabulary.per_page
    else
      @page = 0
      @vocabularies = Vocabulary.search_for(params[:word])
      @search = params[:word].include?(':') ? params[:word].split(':')[1] : params[:word]
    end
    @vocabularies.blank? ? render(:partial => 'vocabularies/empty') : render(:partial => 'vocabularies/vocabularies')
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
      @vocabularies_list = Vocabulary.find :all, :joins => 'LEFT JOIN taggings ON taggings.taggable_id = vocabularies.id', :group => 'vocabularies.id', :having => 'COUNT(taggings.id) = 0'
    else
      @tag = Tag.find_by_id_or_permalink(params[:id])
      @vocabularies_list = Vocabulary.find :all, :conditions => ['taggings.tag_id = ?', @tag.id], :include => [ :taggings ]
    end
    respond
  end
  
  # Display paged list of vocabularies with correspoding tag
  #
  # API information - 
  #   /vocabularies/by_type/#{type}.xml|json (No oauth required)
  def by_type
    conditions = params[:id] == "other" ? "type IS NULL" : "type = '#{params[:id]}'"
    @vocabularies_list = Vocabulary.find :all, :conditions => conditions
    respond
  end
  
  # Display paged list of vocabularies with correspoding tag
  #
  # API information - 
  #   /vocabularies/by_user/#{id|permalink}.xml|json (No oauth required)
  def by_user
    @user = User.find_by_id_or_permalink(params[:id])
    @vocabularies_list = Vocabulary.find_by_user_id @user.id
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
            @page = params.key?(:last) ? params[:last].to_i + 1 : (params.key?(:page) ? params[:page] : 1)
            @vocabularies = @vocabularies_list.paginate :page => @page, :per_page => Vocabulary.per_page
            if @vocabularies.empty?
              render(:nothing => true)
            else
              render :update do |page|
                page.insert_html :bottom, 'vocabulary_results', render(:partial => 'vocabularies', :object => @vocabularies, :locals => {:page => @page})
                page.replace_html 'pagination', will_paginate(@vocabularies)
              end
            end
          }
          format.json { render :json => @vocabularies.to_json(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
          format.xml { render :xml => @vocabularies.to_xml(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] } }) }
        end
      end
    end
  
end