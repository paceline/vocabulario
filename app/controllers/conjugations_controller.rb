class ConjugationsController < ApplicationController
   
  # Filters
  before_filter :admin_required
   
  # Features
  in_place_edit_for :conjugation, :name
  in_place_edit_for :conjugation, :first_person_singular
  in_place_edit_for :conjugation, :second_person_singular
  in_place_edit_for :conjugation, :third_person_singular
  in_place_edit_for :conjugation, :first_person_plural
  in_place_edit_for :conjugation, :second_person_plural
  in_place_edit_for :conjugation, :third_person_plural
  
  # Create a new conjugation (including link to :vocabulary_id if given)
  def create
    @conjugation = Conjugation.new(params[:conjugation])  
    if @conjugation.valid? && @conjugation.errors.empty?
      @conjugation.save
      reference = Vocabulary.find(params[:vocabulary_id]) if params[:vocabulary_id]
      reference.conjugations << @conjugation if reference
      flash[:success] = "\"#{@conjugation.name}\" has been added to the database."
      redirect_to @conjugation
    else
      render :action => 'new'
    end
  end
  
  # Delete a conjugation
  def destroy
    conjugation = Conjugation.find(params[:id])
    conjugation.verbs.clear
    conjugation.destroy
    render :update do |page|
      page.remove "conjugation_#{params[:id]}"
      page.visual_effect :highlight, 'conjugations'
    end
  end
  
  # List conjugations
  def index
    tense = ConjugationTime.find(params[:conjugation_time_id])
    @conjugations = tense.conjugations
    render @conjugations
  end
  
  # Present a new conjugation form (including link to :vocabulary_id if given)
  def new
    @conjugation = Conjugation.new
    @path = conjugations_path
    if params[:vocabulary_id]
      @vocabulary = Vocabulary.find_by_id_or_permalink(params[:vocabulary_id])
      @path = vocabulary_conjugations_path(@vocabulary)
    end
  end
  
  # Shows details for a conjugation
  def show
    @conjugation = Conjugation.find(params[:id])
  end
  
end
