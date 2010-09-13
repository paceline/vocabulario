class RulesController < ApplicationController
  
  # Filters
  before_filter :admin_required
  
  # List alle rules
  def autocomplete
    @rules = Rule.find :all, :conditions => "find LIKE '#{params[:find]}%'"
    render :partial => 'rules'
  end
  
  # Create a new rule or link pattern to existing one
  def create
    @pattern = Pattern.find params[:pattern_id]
    rule = Rule.find_or_initialize_by_find_and_replace params[:rule][:find], params[:rule][:replace], :name => params[:rule][:name]
    @pattern.rules << rule
    @pattern.save if rule.valid? && rule.errors.empty?
    redirect_to @pattern 
  end
  
  # Edit a rule
  def edit
    @rule = Rule.find params[:id]
    render 'new'
  end
  
  # Open new rule form
  def new
    @rule = Rule.new
  end
  
  # Show rule (only needed for json)
  def show
    rule = Rule.find params[:id]
    respond_to do |format|
      format.json { render :json => rule }
    end
  end
  
  # Test a (new) rule against sample verb
  def test
    if !params[:rule][:find].blank? && !params[:rule][:replace].blank? && !params[:verb].blank?
      @rule = Rule.new params[:rule] 
      sub = @rule.find_and_replace params[:verb]
      render :text => (sub ? sub : '<i>No match</i>')
    else
      render :nothing => true
    end
  end
  
  # Update current rule
  def update
    @rule = Rule.find params[:id]
    @rule.update_attributes params[:rule]
    flash[:success] = "Rule has been updated."
    render 'new'
  end
end