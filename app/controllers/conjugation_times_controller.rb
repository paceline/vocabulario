class ConjugationTimesController < ApplicationController
  
  # Filters
  before_filter :admin_required
  
  # Features
  in_place_edit_for :conjugation_time, :name
  in_place_edit_for :conjugation_time, :language_id, { :method => :word }
  
  # Create a new tense
  def create
    @time = ConjugationTime.new(params[:conjugation_time])
    if @time.valid? && @time.errors.empty?
      @time.save
      flash[:success] = "\"#{@time.name}\" has been added to the database."
      redirect_to conjugation_times_path
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
    @languages = Language.find(:all, :order => 'word')
    @tenses = params.key?(:menu) ? @languages[params[:menu].to_i].conjugation_times : @languages.first.conjugation_times
    @tense = @tenses.first
    @active = 0
    @patterns = @tense.patterns unless @tenses.blank?
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace_html :tab_browser, render(:partial => 'list')
          page.replace_html :patterns, render(:partial => 'patterns/list')
        end 
      }
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
    render 'index'
  end
  
end
