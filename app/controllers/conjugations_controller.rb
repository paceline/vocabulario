class ConjugationsController < ApplicationController
  # Layout
  layout 'default'
  
  # Features
  in_place_edit_for :conjugation, :name
  
  # Create a new conjugation (including link to :vocabulary_id if given)
  def create
    @conjugation = Conjugation.new(params[:conjugation])  
    if @conjugation.valid? && @conjugation.errors.empty?
      @conjugation.save
      reference = Vocabulary.find(params[:vocabulary_id]) if params[:vocabulary_id]
      reference.conjugations << @conjugation if reference
      flash[:notice] = render_notice("Great", "\"#{@conjugation.name}\" has been added to the database.")
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
  
  # Present a new conjugation form (including link to :vocabulary_id if given)
  def new
    @conjugation = Conjugation.new
    @path = conjugations_path
    if params[:vocabulary_id]
      @vocabulary = Vocabulary.find(params[:vocabulary_id])
      @path = vocabulary_conjugations_path(@vocabulary)
    end
  end
  
  # Shows details for a conjugation
  def show
    @conjugation = Conjugation.find(params[:id])
  end
  
end
