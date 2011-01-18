class PatternsController < ApplicationController
  
  # Filters
  before_filter :admin_required
  before_filter :browser_required
  
  # Add self to a verb
  def add_verb
    pattern = Pattern.find params[:id]
    verb = Verb.find params[:verb_id]
    verbs = pattern.verbs << verb
    insert_at = verbs.index(verb) == verbs.size-1 ? -1 : verbs[verbs.index(verb)+1].id
    respond_to do |format|
      format.js {
        render :update do |page|
          page.toggle "assigned_none" if verbs.size == 1
          page.remove "unassigned_#{verb.id}"
          if insert_at == -1
            page.insert_html :bottom, "assigned", render(verb)
          else
            page.insert_html :before, "assigned_#{insert_at}", render(verb)
          end
        end 
      }
    end
  end
  
  # Delete a pattern
  def destroy
    pattern = Pattern.find params[:id]
    conjugation_time = pattern.conjugation_time
    pattern.destroy
    redirect_to tense_path(conjugation_time.permalink)
  end
  
  # Add self to a verb
  def remove_verb
    pattern = Pattern.find params[:id]
    verb = Verb.find params[:verb_id]
    pattern.verbs.delete verb
    unassigned = pattern.auto_detect_verbs
    insert_at = unassigned.index(verb) == unassigned.size-1 ? -1 : unassigned[unassigned.index(verb)+1].id
    respond_to do |format|
      format.js {
        render :update do |page|
          pattern.verbs.size >= 1 ? page.hide("assigned_none") : page.show("assigned_none")
          page.remove "assigned_#{verb.id}"
          if insert_at == -1
            page.insert_html :bottom, "unassigned", render(:partial => 'verbs/draggable_verb', :object => verb)
          else
            page.insert_html :before, "unassigned_#{insert_at}", render(:partial => 'verbs/draggable_verb', :object => verb)
          end
        end 
      }
    end
  end
  
  # List conjugations
  def index
    @tense = ConjugationTime.find_by_id_or_permalink params[:tense_id]
    @patterns = @tense.patterns
    respond_to do |format|
      format.js { render(:update) { |page| page.replace_html 'patterns', render(:partial => 'list') } }
    end
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
