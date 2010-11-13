class VocabularyTest < LanguageTest
  
  # Readers for member variables
  attr_reader :from, :to
  
  # Setup a new vocabulary test based on a vocabulary list
  def setup_based_on_list(list_id, options)
    list = List.find(list_id)
    @from = options.key?(:reverse) && options[:reverse] == 'true' ? list.language_to : list.language_from
    @to = options.key?(:reverse) && options[:reverse] == 'true' ? list.language_from : list.language_to
    @limit = options[:limit].to_i if options.key?(:limit)
    @tags = list.tag_list
    generate_test(options.key?(:reverse) && options[:reverse] == 'true' ? list.vocabularies_to_translations : list.vocabularies)
  end
  
  # Setup a new vocabulary test based on params (language, tags, etc.)
  def setup_based_on_params(options)
    if options.key?(:to) && options.key?(:from)
      @from = Vocabulary.find(options[:from])
      @to = Vocabulary.find(options[:to])
      raise(ActiveRecord::RecordNotFound, "At least one of the languages not found. Probably either a typ-o or unsupported language.") unless @to && @from
      @limit = options[:limit].to_i if options.key?(:limit)
      @tags = options[:tags] if options.key?(:tags)
      options.key?(:current) && options.key?(:test) ? restore_test(options[:current].to_i, options[:test]) : generate_test(@tags ? Vocabulary.find_tagged_with(@tags, :match_all => Boolean(options[:all_or_any]), :conditions => "language_id = #{@from.id}") : @from.vocabularies)
    else
      raise(ArgumentError, "Missing options. :to and :from are required at minimum.")
    end
  end
  
  # Returns result for current question (answer true/false)
  def result_for(response = "")
    return correct_results.include?(response)
  end
  
  # Returns set of correct results for current question
  def correct_results
    load_current_question
    return @test[@current][1].collect { |result| result.word }
  end
  
  # Returns parameters required to re-invoke vocabulary test
  def to_session_params
    return { 
      :from => @from.id,
      :to => @to.id,
      :limit => @limit,
      :current => @current,
      :test => @test.collect { |t| t.class == Fixnum ? t : t.first.id }
    }
  end
  
  # Returns json for web service calls
  def as_json(options = {})
    {
      :vocabulary_test => {
        :from => { :id => @from.id, :word => @from.word },
        :to => { :id => @to.id, :word => @to.word },
        :answers => (options.key?(:answers) ? options[:answers].collect { |i| i } : []),
        :next_question => { :id => current_question.id, :type => current_question.class_type, :word => current_question.word, :gender => current_question.gender },
        :score => { :id => options[:score].id, :points => options[:score].points, :questions => options[:score].questions },
        :current => @current,
        :limit => @limit,
        :continue => continue?
      }
    }
  end
  
  # Returns xml for web service calls
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.vocabulary_test do
      xml.from do 
        xml.tag!(:id, @from.id)
        xml.tag!(:word, @from.word)
      end
      xml.to do 
        xml.tag!(:id, @to.id)
        xml.tag!(:word, @to.word)
      end
      if options.key?(:answers)
        xml.answers do
          0.upto(options[:answers].size-1) { |i| xml.tag!("answer_#{i+1}", options[:answers][i]) }
        end
      end
      xml.next_question do 
        xml.tag!(:id, current_question.id)
        xml.tag!(:type, current_question.class_type)
        xml.tag!(:word, current_question.word)
        xml.tag!(:gender, current_question.gender)
      end
      xml.score do
        xml.tag!(:id, options[:score].id)
        xml.tag!(:points, options[:score].points)
        xml.tag!(:questions, options[:score].questions)
      end
      xml.tag!(:current, @current)
      xml.tag!(:limit, @limit)
      xml.tag!(:continue, continue?)
    end
  end

end