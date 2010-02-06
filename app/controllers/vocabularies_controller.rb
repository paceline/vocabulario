class VocabulariesController < ApplicationController
  
  # Filters
  before_filter :browser_required, :except => [:index, :show]
  before_filter :login_required, :except => [:index, :refresh_language, :select, :show]
  before_filter :admin_required, :only => [:destroy]
  
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
    flash.now[:success] = "#{@vocabulary.word}'s tags have been copied to all translations."
    render :update do |page|
      page.replace_html :notice, render(:partial => 'layouts/flashes')
      page.show :notice
    end
  end
  
  # Apply vocabulary's type to all translations
  def apply_type
    @vocabulary = Vocabulary.find(params[:id])
    @vocabulary.apply_type_to_translations
    flash.now[:success] = "#{@vocabulary.word}'s type has been copied to all translations."
    render :update do |page|
      page.replace_html :notice, render(:partial => 'layouts/flashes')
      page.show :notice
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
          render :text => "var vocabularies = new Array('" + @vocabularies_list.collect { |v| v.word }.join("','") + "');"
        end
      }
      format.json { render :json => @vocabularies_list.to_json(:except => [:user_id, :language_id], :include => [ :language, :translation_to ]) }
      format.xml { render :xml => @vocabularies_list.to_xml(:except => [:user_id, :language_id], :include => [ :language, :translation_to ]) }
    end
  end
  
  # Import CSV file using FasterCSV
  def import
    if request.post?
      begin
        FasterCSV.parse(params[:vocabulary][:file].read, { :col_sep => ';', :row_sep => :auto }) do |row|
          if @from && @to
            vocabulary = Object.const_get(row[1].strip).find_or_initialize_by_word(row[0].strip) { |v| v.language = @from }
            vocabulary.import(current_user, params[:vocabulary][:tags])
            row[2..row.size-1].each do |translations|
              if translations
                translation = Object.const_get(row[1].strip).find_or_initialize_by_word(translations) { |v| v.language = @to }
                translation.import(current_user, params[:vocabulary][:tags])
                vocabulary.translation_to << translation if vocabulary.new_record? || translation.new_record?
                translation.save
              end
            end
            vocabulary.save
          else
            @from = Language.find_by_word(row[0].strip)
            @to = Language.find_by_word(row[2].split(' ').first.strip)
          end
        end
        flash.now[:success] = "Vocabularies have been imported to the database."
      rescue Exception => @exception
        flash.now[:failure] = "Something went wrong here..."
      end
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
      @vocabulary = Vocabulary.find_by_id_or_permalink(params[:id])
      @language = @vocabulary.language
      if @vocabulary.verb?
        @conjugations = @vocabulary.conjugations
        @transformations = @vocabulary.transformations
        @transformation = Transformation.new
      end
      respond_to do |format|
        format.html
        format.js {
          @display_transformations = @conjugations.empty? ? "display: none;" : "display: visible;" if @vocabulary.verb?
          render :partial => "show_tab_#{params[:menu]}"
        }
        format.json { render :json => @vocabulary.to_json(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] }, :translation_from => {:include => {:language => {:only => [:id, :word]}}}, :translation_to => {:include => {:language => {:only => [:id, :word]}}}}) }
        format.xml { render :xml => @vocabulary.to_xml(:except => [:user_id, :language_id], :include => { :language => { :only => [:id, :word] }, :translation_from => {:include => {:language => {:only => [:id, :word]}}}, :translation_to => {:include => {:language => {:only => [:id, :word]}}}}) }
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
