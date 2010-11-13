class ScoresController < ApplicationController
  
  # Filters
  before_filter :browser_required, :only => [:update_languages, :update_tags, :options_for_list]
  before_filter :web_service_authorization_required
  
  # Open up a new language test
  def new
    @score = Score.new
    if params[:menu] == '2' || params[:list_id]
      @lists = List.find_public(current_user)
      @list = params[:list_id] ? List.find_by_id_or_permalink(params[:list_id]) : @lists.first
    else
      @languages = Language.list
      @tags = @languages.first.tags_for_language
    end
    respond_to do |format|
      format.html
      format.js { render :partial => "new_test_tab_#{params[:menu]}" }
    end
  end
  
  # Return the ten top scores
  #
  # API information - 
  #   /scores.xml|json (Oauth required)
  def index
    @scores = Score.top_percentage(10)
    respond_to do |format|
      format.html
      format.json { render :json => @scores.to_json(:except => [:language_from_id, :language_to_id, :user_id, :confirmation_token, :encrypted_password, :email, :email_confirmed, :remember_token, :salt], :include => [:language_from, :language_to, :user]) }
      format.xml { render :xml => @scores.to_xml(:except => [:language_from_id, :language_to_id, :user_id, :confirmation_token, :encrypted_password, :email, :email_confirmed, :remember_token, :salt], :include => [:language_from, :language_to, :user]) }
    end
  end
  
  # Create a new vocabulary test (on "Let's go")
  #
  # API information - 
  #   /scores.xml|json (post, Oauth required)
  def create
    params[:test].delete(:limit) if params[:test][:limit] == 'all'
    @test = params[:test][:list_id] ? Object.const_get(params[:type]).new(params[:test].delete(:list_id), params[:test]) : Object.const_get(params[:type]).new(params[:test])
    if @test.empty?
      respond_to do |format|
        format.js {
          flash.now[:failure] = "Sorry, no vocabularies were found based on your selection."
          render(:update) { |page| page.update_notice }
        }
        format.all { internal_server_error }
      end
    else
      @score = Score.new({ :user_id => current_user, :questions => @test.current, :test_type => @test.class.to_s })
      @score.setup(@test)
      @score.save
      respond_to do |format|
        format.js
        format.json { render :json => @test.as_json(:score => @score) }
        format.xml { render :xml => @test.to_xml(:score => @score) }
      end
    end
  end
  
  # Update current vocabulary test (on answers)
  #
  # API information - 
  #   /scores.xml|json (put, Oauth required)
  def update
    @test = Object.const_get(params[:type]).new params[:test_object]
    @score = Score.find params[:id]
    if @test.class == ConjugationTest
      answers = Array.new(6) { |i| params['answers'][i.to_s] }
      @results = @test.result_for(answers)
      result = @score.evaluate_result 6, !@results.include?(false), @test.count_correct_results(@results)
    else
      result = @score.evaluate_result 1, @test.result_for(params[:answer])
    end
    @correct_results = @test.correct_results
    @test.current += 1
    @score.save
    respond_to do |format|
      format.js {
        if @test.class == ConjugationTest
          result ? flash.now[:success] = "You got everything right." : flash.now[:failure] = "Unfortunately you made some mistakes. See below for the correct answers."
        else
          result ? flash.now[:success] = "That's correct. Well done. Its <strong>#{@correct_results.join(', ')}</strong> in #{@test.to.word}." : flash.now[:failure] = "Unfortunately that's not correct. Its <strong>#{@correct_results.join(', ')}</strong> in #{@test.to.word}"
        end
      }
      format.json { render :json => @test.as_json(:score => @score, :answers => @test.correct_results) }
      format.xml { render :xml => @test.to_xml(:score => @score, :answers => @test.correct_results) }
    end
  end
  
  # /scores/new support: Make sure to and from select boxes always have different selected languages
  def update_languages
    @languages = Language.list("id != #{params[:language_from_id]}")
    @language_from = Vocabulary.find(params[:language_from_id])
    @language_to = params[:language_from_id] == params[:language_to_id] ? @languages.first : @languages.fetch_object(:id, params[:language_to_id].to_i)   
    @tags = @language_from.tags_for_language & @language_to.tags_for_language
    render :update do |page|
      page.replace_html 'test_to', options_for_select(@languages.collect {|p| [p.word, p.id ] }, @language_to.id)
      page.replace_html 'test_tags', options_for_select(@tags.collect {|t| t.name })
    end
  end
  
  # /scores/new support: Update tags select box based on seleted language 
  def update_tags
    @language_from = params.key?(:conjugation_time_id) ? ConjugationTime.find(params[:conjugation_time_id]).language : Vocabulary.find(params[:language_from_id])
    @language_to = Vocabulary.find(params[:language_to_id]) unless params.key?(:conjugation_time_id)
    @tags = params.key?(:conjugation_time_id) ? @language_from.tags_for_language : @language_from.tags_for_language & @language_to.tags_for_language
    render(:update) { |page| page.replace_html 'test_tags', options_for_select(@tags.collect {|t| t.name }) }
  end
  
  # /scores/new support: Update directions based on list selected
  def options_for_list
    @list = List.find(params[:list_id])
    render :partial => 'options_for_list'
  end

end
