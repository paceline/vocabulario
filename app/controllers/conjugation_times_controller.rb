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
    @conjugations = @tenses.first.conjugations unless @tenses.blank?
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace_html :tab_browser, render(:partial => 'list')
          page.replace_html :patterns, render(@conjugations)
        end 
      }
    end
  end
  
  # Present a new tense form
  def new
    @time = ConjugationTime.new
  end
  
  # Shows details for a tense
  def show
    @conjugation_time = ConjugationTime.find(params[:id])
  end
  
end
