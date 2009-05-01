class ScoresController < ApplicationController
  layout 'default'
  
  def new
    @score = Score.new
  end
  
  def index
    @scores = Score.top_percentage(10)
  end
  
  def create
    if params[:test][:from] != params[:test][:to]
      session[:test] = VocabularyTest.new(params[:test])
      @score = session[:test].from.scores.create({ :user_id => current_user, :questions => session[:test].current })
      render :update do |page|
        page.hide :intro_pane
        page.replace_html 'test_pane', render(:partial => 'question', :object => session[:test])
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
  
  def update
    @score = Score.find(params[:test][:score_id])
    if session[:test].result_for(params[:test][:answer])
      @score.points += 1
      flash.now[:notice] = "That's correct. Well done. #{session[:test].from.word} - #{session[:test].correct_results.join(', ')}."
    else
      flash.now[:notice] = "Unfortunately that's not correct. #{session[:test].from.word} - #{session[:test].correct_results.join(', ')}."
    end
    session[:test].current += 1
    @score.questions += 1
    @score.save
    
    render :update do |page|
      page.replace_html 'test_pane', render(:partial => (session[:test].continue? ? 'question' : 'finish'), :object => session[:test])
      page.replace_html :notice, flash[:notice]
      page.show :notice
      page.visual_effect :highlight, 'notice'
      page.replace_html 'test_score', render(@score)
      page.visual_effect :highlight, 'test_score'
    end
  end

end
