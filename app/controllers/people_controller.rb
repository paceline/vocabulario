class PeopleController < ApplicationController
  
  # Filters
  before_filter :admin_required
  before_filter :browser_required
  
  # Features
  in_place_edit_for :person, :pronoun
  in_place_edit_for :person, :language_id, { :method => :word }
  in_place_edit_for :person, :first_person_singular
  in_place_edit_for :person, :second_person_singular
  in_place_edit_for :person, :third_person_singular
  in_place_edit_for :person, :first_person_plural
  in_place_edit_for :person, :second_person_plural
  in_place_edit_for :person, :third_person_plural
  
  # Create a new set of pronouns
  def create
    @person = Person.new(params[:person])
    if @person.valid? && @person.errors.empty?
      @person.save
      flash[:success] = "Your set of #{@person.pronoun} pronouns has been added to the database."
      redirect_to @person
    else
      render :action => 'new'
    end
  end
  
  # Delete set of pronouns
  def destroy
    @person = Person.find(params[:id])
    language_id = @person.language.id
    @person.destroy
    render :update do |page|
      page.remove "pronoun_#{params[:id]}"
      page.visual_effect :highlight, "pronouns_#{language_id}"
    end
  end
  
  # List currently supported pronouns
  def index
    @languages = Language.find(:all, :order => 'word')
  end
  
  # Enter a new set of pronouns
  def new
    @person = Person.new
  end
  
  # Show a new set of pronouns
  def show
    @person = Person.find(params[:id])
  end
  
end
