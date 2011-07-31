class RulesController < ApplicationController
  
  # Filters
  before_filter :admin_required
  before_filter :browser_required, :except => :show
  
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
  
  # Delete a rule
  def destroy
    rule = Rule.find params[:id]
    pattern = Pattern.find params[:pattern_id]
    pattern.rules.delete rule
    rule.destroy unless rule.has_patterns?
    render :update do |page|
      page << "Effect.DropOut('list_item_#{params[:id]}')"
    end
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
      format.html { redirect_to edit_pattern_rule_path(params[:pattern_id], params[:id]) }
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
    @current_rule = Rule.find params[:id]
    if params[:rule][:save_as_new].to_i == 1
      @pattern = Pattern.find params[:pattern_id]
      @rule = Rule.new params[:rule]
      if @rule.valid? && @rule.errors.empty?
        @pattern.rules.delete @current_rule
        @pattern.rules << @rule
        @pattern.save
        flash[:notice] = "Rule has been saved as new."
        redirect_to pattern_path(params[:pattern_id])
      else
        render 'new'
      end
    else
      @current_rule.update_attributes params[:rule]
      flash[:notice] = "Rule has been updated."
      redirect_to pattern_path(params[:pattern_id])
    end
  end
end