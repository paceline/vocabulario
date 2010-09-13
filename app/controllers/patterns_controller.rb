class PatternsController < ApplicationController
  
  # Filters
  before_filter :admin_required
  
  # Features
  in_place_edit_for :pattern, :name
  
  # List conjugations
  def index
    @tense = ConjugationTime.find(params[:conjugation_time_id])
    @patterns = @tense.patterns
    render :partial => 'list'
  end
  
  # Create a new conjugation (including link to :vocabulary_id if given)
  def create
    @pattern = Pattern.new(params[:pattern])  
    if @pattern.valid? && @pattern.errors.empty?
      @pattern.save
      flash[:success] = "New pattern has been added to the database."
      redirect_to @pattern
    else
      render :action => 'new'
    end
  end
  
  # Present a new conjugation form (including link to :vocabulary_id if given)
  def new
    @pattern = Pattern.new
  end
  
  # Reorder a conjugation
  def reorder
    @pattern = Pattern.find(params[:id]) 
    @pattern.patterns_rules.each do |t|
      t.position = params['rules'].index(t.rule_id.to_s) + 1
      t.save 
    end 
    render :nothing => true
  end
  
  # Present a pattern
  def show
    @pattern = Pattern.find params[:id]
  end
  
end
