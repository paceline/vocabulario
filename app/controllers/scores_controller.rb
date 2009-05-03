class ScoresController < ApplicationController
  # Layout
  layout 'default'
  
  # Open up a new vocabulary test
  def new
    @score = Score.new
    @languages = Vocabulary.languages
    @tags = @languages.first.tags_for_language
  end
  
  # Return top scores
  def index
    @scores = Score.top_percentage(10)
  end
  
  # Create a new vocabulary test (on "Let's go")
  def create
    if params[:test][:from] != params[:test][:to]
      test = VocabularyTest.new(params[:test])
      @score = test.from.scores.create({ :user_id => current_user, :questions => test.current })
      session[:test] = test.to_session_params
      render :update do |page|
        page.hide :intro_pane
        page.replace_html 'test_pane', render(:partial => 'question', :object => test)
        page.visual_effect :highlight, 'test_pane'
        page.replace_html 'test_score', render(@score)
        page.visual_effect :highlight, 'test_score'
      end
    else
      flash[:notice] = "It's a vocabulary test. You probably want to select two different languages."
      render :update do |page|
        page.replace_html :notice, flash[:notice]
        page.toggle :notice
        page.visual_effect :highlight, 'error'
        flash.discard
      end
    end
  end
  
  # Update current vocabulary test (on answers)
  def update
    test = VocabularyTest.new(session[:test])
    @score = Score.find(params[:test][:score_id])
    if test.result_for(params[:test][:answer])
      color = '#C0ED00'
      @score.points += 1
      flash.now[:notice] = "<b>Yes</b>, that's correct. Well done. Its <b>#{test.correct_results.join(', ')}</b> in #{test.to.word}."
    else
      color = '#C66'
      flash.now[:notice] = "<b>No</b>, unfortunately that's not correct. Its <b>#{test.correct_results.join(', ')}</b> in #{test.to.word}."
    end
    session[:test][:current] = test.current += 1
    @score.questions += 1
    @score.save
    
    render :update do |page|
      page.replace_html 'test_pane', render(:partial => (test.continue? ? 'question' : 'finish'), :object => test)
      page.replace_html :notice, flash[:notice]
      page << "$('notice').setStyle({ backgroundColor: '#{color}' })"
      page.show :notice
      page.visual_effect :highlight, 'notice'
      page.replace_html 'test_score', render(@score)
      page.visual_effect :highlight, 'test_score'
    end
  end

end
