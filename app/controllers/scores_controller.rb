class ScoresController < ApplicationController
  
  # Open up a new language test
  def new
    @score = Score.new
    if params[:menu] == 'translate_by_list'
      @lists = List.find_public(current_user)
      @from = @lists.first.language_from.word
      @to = @lists.first.language_to.word
    else
      @languages = Language.list
      @tags = @languages.first.tags_for_language
    end
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page << "['translate_by_tag','translate_by_list','conjugate'].collect(function(v) { $(v + '_link').className = 'tab_link'; })"
          page << "$('#{params[:menu]}_link').addClassName('active')"
          page.replace_html 'test_pane', render(:partial => "new_#{params[:menu]}")
        end
      }
    end
  end
  
  # Return top scores
  def index
    @scores = Score.top_percentage(10)
  end
  
  # Create a new vocabulary test (on "Let's go")
  def create
    params[:test].delete(:limit) if params[:test][:limit] == 'all'
    @test = params[:test][:list_id] ? Object.const_get(params[:type]).new(params[:test].delete(:list_id), params[:test]) : Object.const_get(params[:type]).new(params[:test])
    if @test.empty?
      flash.now[:failure] = "Sorry, no vocabularies were found based on your selection."
      render(:update) { |page| page.update_notice }
    else
      @score = Score.new({ :user_id => current_user, :questions => @test.current, :test_type => @test.class.to_s })
      @score.setup(@test)
      @score.save
      session[:test] = @test.to_session_params
      render :update do |page|
        page.hide :test_tabs
        page << "$('test_pane').className = ''"
        page.replace_html 'test_pane', render(@test)
        page.visual_effect :highlight, 'test_pane'
        page.replace_html 'test_score', render(@score)
        page.visual_effect :highlight, 'test_score'
      end
    end
  end
  
  # Update current vocabulary test (on answers)
  def update
    @test = Object.const_get(params[:type]).new(session[:test])
    @score = Score.find(params[:score_id])
    if @test.class == ConjugationTest
      answers = []
      1.upto(6) { |i| answers << params['test'][i.to_s] }
      @results = @test.result_for(answers)
      @score.points += @test.count_correct_results(@results)
      if !@results.include?(false)
        flash.now[:success] = "You got everything right."
      else
        @correct_results = @test.correct_results
        flash.now[:failure] = "Unfortunately you made some mistakes. See below for the correct answers."
      end
      @score.questions += 6
    else
      if @test.result_for(params[:test][:answer])
        @score.points += 1
        flash.now[:success] = "That's correct. Well done. Its <strong>#{@test.correct_results.join(', ')}</strong> in #{@test.to.word}."
      else
        flash.now[:failure] = "Unfortunately that's not correct. Its <strong>#{@test.correct_results.join(', ')}</strong> in #{@test.to.word}"
      end
      @score.questions += 1
    end
    session[:test][:current] = @test.current += 1
    @score.save
    
    render :update do |page|
      if @correct_results
        page.replace_html 'error_pane', render(:partial => 'shared/correct_results')
        page.show :error_pane
      else
        page.hide :error_pane
      end
      page.replace_html 'test_pane', render(@test)
      page.replace_html 'test_score', render(@score)
      page.update_notice
      page.visual_effect :highlight, 'test_score'
    end
  end
  
  # /scores/new support: Make sure to and from select boxes always have different selected languages
  def update_languages
    @languages = Language.list("id != #{params[:language_from_id]}")
    @language_from = Vocabulary.find(params[:language_from_id])
    @language_to = params[:language_from_id] == params[:language_to_id] ? @languages.first : @languages.fetch_object(:id, params[:language_to_id].to_i)   
    @tags = @language_from.tags_for_language & @language_to.tags_for_language
    render :update do |page|
      page.replace_html 'test_to', options_for_select(@languages.collect {|p| [p.word, p.id ] }, @language_to)
      page.replace_html 'test_tags', options_for_select(@tags.collect {|t| [t.name, t.id ] })
    end
  end
  
  # /scores/new support: Update tags select box based on seleted language 
  def update_tags
    @language_from = params.key?(:conjugation_time_id) ? ConjugationTime.find(params[:conjugation_time_id]).language : Vocabulary.find(params[:language_from_id])
    @language_to = Vocabulary.find(params[:language_to_id]) unless params.key?(:conjugation_time_id)
    @tags = params.key?(:conjugation_time_id) ? @language_from.tags_for_language : @language_from.tags_for_language & @language_to.tags_for_language
    render(:update) { |page| page.replace_html 'test_tags', options_for_select(@tags.collect {|t| [t.name, t.id ] }) }
  end
  
  # /scores/new support: Update directions based on list selected
  def direction_for_list
    list = List.find(params[:list_id])
    @from = list.language_from.word
    @to = list.language_to.word
    render :partial => 'direction_for_list'
  end

end
