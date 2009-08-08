class ScoresController < ApplicationController
  # Layout
  layout 'default'
  
  # Open up a new language test
  def new
    @score = Score.new
    @languages = Language.list
    @tags = @languages.first.tags_for_language
    if params[:menu]
      render :update do |page|
        page << "['vocabulary','conjugation'].collect(function(v) { $(v + '_test_link').className = 'tab_link'; })"
        page << "$('#{params[:menu]}_test_link').addClassName('active')"
        page.replace_html 'test_pane', render(:partial => "#{params[:menu]}_test/#{params[:menu]}_test")
      end
    end
  end
  
  # Return top scores
  def index
    @scores = Score.top_percentage(10)
  end
  
  # Create a new vocabulary test (on "Let's go")
  def create
    @test = Object.const_get(params[:type]).new(params[:test])
    @score = Score.new({ :user_id => current_user, :questions => @test.current, :test_type => @test.class.to_s })
    @score.language_from_id = params[:test][:from] ? @test.from.id : ConjugationTime.find(params[:test][:tense]).language.id
    @score.language_to_id = params[:test][:to] ? @test.to.id : @score.language_from_id
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
  
  # Update current vocabulary test (on answers)
  def update
    @test = Object.const_get(params[:type]).new(session[:test])
    @score = Score.find(params[:score_id])
    if @test.class == ConjugationTest
      answers = []
      1.upto(6) { |i| answers << params['test'][i.to_s] }
      @results = @test.result_for(answers)
      @score.points += @results.count(true)
      if !@results.include?(false)
        color = '#C0ED00'
        flash.now[:notice] = render_notice("Yes", "You got everything right.")
      else
        @correct_results = @test.correct_results
        color = '#C66'
        flash.now[:notice] = render_notice("No", "Unfortunately you made some mistakes. See below for the correct answers.")
      end
      @score.questions += 6
    else
      if @test.result_for(params[:test][:answer])
        color = '#C0ED00'
        @score.points += 1
        flash.now[:notice] = render_notice("Yes", "That's correct. Well done. Its <strong>#{@test.correct_results.join(', ')}</strong> in #{@test.to.word}.")
      else
        color = '#C66'
        flash.now[:notice] = render_notice("No", "Unfortunately that's not correct. Its <strong>#{@test.correct_results.join(', ')}</strong> in #{@test.to.word}")
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
      page.replace_html :notice, flash[:notice]
      page << "$('notice').setStyle({ backgroundColor: '#{color}' })"
      page.show :notice
      page.visual_effect :highlight, 'notice'
      page.replace_html 'test_score', render(@score)
      page.visual_effect :highlight, 'test_score'
    end
  end

end
