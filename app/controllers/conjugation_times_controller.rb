class ConjugationTimesController < ApplicationController
  
  # Filters
  before_filter :admin_required, :except => [:index, :show, :tab]
  before_filter :browser_required, :except => [:index, :show]
  
  # Standard formats
  respond_to :js
  
  # Create a new tense
  def create
    @time = ConjugationTime.new(params[:conjugation_time])
    if @time.valid? && @time.errors.empty?
      @time.save
      flash[:notice] = "\"#{@time.name}\" has been added to the database."
      redirect_to tenses_path
    else
      render :action => 'new'
    end
  end
  
  # Delete a tense
  def destroy
    tense = ConjugationTime.find(params[:id])
    tense.destroy
    render :update do |page|
      page.remove "conjugation_time_#{params[:id]}"
      page.visual_effect :highlight, 'conjugation_times'
    end
  end
  
  # List tenses
  def index
    if params.key? :language_id
      @tenses = Language.find(params[:language_id]).conjugation_times
      respond_to do |format|
        format.json { render :json => @tenses.to_json(:except => :language_id) }
        format.xml { render :xml => @tenses.to_xml(:except => :language_id) }
      end
    else
      if params.key? :all
         @tenses = ConjugationTime.find :all, :order => "language_id, name"
      else
        @languages = Language.find(:all, :order => 'word')
        @tenses = @languages.first.conjugation_times
        @tense = @tenses.first
        @active = 0
        @patterns = @tense.patterns unless @tenses.blank?
      end
      respond_to do |format|
        format.html
        format.json { render :json => @tenses.to_json(:except => :language_id, :include => { :language => { :only => [:id, :word] } }) }
        format.xml { render :xml => @tenses.to_xml(:except => :language_id, :include => { :language => { :only => [:id, :word] } }) }
      end
    end
  end
  
  # Live search of the pattern database
  def live
    @tense = ConjugationTime.find_by_id_or_permalink params[:id]
    @search = params[:name]
    if @search.blank?
      @patterns = @tense.patterns
      render @patterns
    else
      @patterns = @tense.patterns.find :all, :conditions => ['name LIKE ?',"%#{@search}%"], :limit => 100
      @patterns.blank? ? render(:nothing => true) : render(@patterns)
    end
  end
  
  # Present a new tense form
  def new
    @time = ConjugationTime.new
  end
  
  # Show tense
  def show
    @languages = Language.find(:all, :order => 'word')
    @tense = ConjugationTime.find_by_id_or_permalink params[:id]
    @active = @languages.index @tense.language
    @tenses = @tense.language.conjugation_times
    @patterns = @tense.patterns
    respond_to do |format|
      format.html { render 'index' }
      format.json { render :json => @tense.to_json(:except => :language_id, :include => { :language => { :only => [:id, :word] } }) }
      format.xml { render :xml => @tense.to_xml(:except => :language_id, :include => { :language => { :only => [:id, :word] } }) }
    end
  end
  
  # Switch tabs
  def tab
    @tenses = Language.find(:all, :order => 'word')[params[:menu].to_i].conjugation_times
    @tense = @tenses.first
    @patterns = @tense.patterns unless @tenses.blank?
    respond_with(@tenses, @tense, @patterns)
  end
  
  # Dynamic loading of tabs
  def tabs
    respond_with(@languages = Language.count, @tense = Language.find(:first, :order => 'word').conjugation_times.first)
  end
  
end
