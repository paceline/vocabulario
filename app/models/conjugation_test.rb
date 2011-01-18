class ConjugationTest < LanguageTest
  
  # Readers for member variables
  attr_reader :tense
  
  # Own class name
  def self.model_name
    ConjugationTest
  end
  
  # Path to partial
  def self.partial_path
    'conjugation_test'
  end
  
  # Setup a new vocabulary test based on a vocabulary list
  def setup_based_on_list(list_id, options)
    setup_common_options(options)
    list = List.find(list_id)
    @tags = list.tag_list
    generate_test(clean_verb_selection(list.vocabularies, options[:tense_id]))
  end

  # Setup a new vocabulary test based on params (language, tags, etc.)
  def setup_based_on_params(options)
    setup_common_options(options)
    @tags = options[:tags] if options.key?(:tags)
    options.key?(:current) && options.key?(:test) ? restore_test(options[:current].to_i, options[:test]) : generate_test(@tags ? clean_verb_selection(@tense.verbs_tagged_with(Boolean(options[:all_or_any]), @tags), @tense.id) : clean_verb_selection(@tense.verbs, @tense.id))
  end
  
  # Counts correct results in given result array
  def count_correct_results(result = [])
    i = 0
    result.each do |r|
      i += 1 if r
    end
    return i
  end
  
  # Returns result for current question (answer true/false)
  def result_for(response = [])
    result = []
    0.upto(response.size-1) do |i|
      result << (response[i] == correct_results[i])
    end
    return result
  end
  
  # Returns set of correct results for current question
  def correct_results
    load_current_question
    return @test[@current][1]
  end
  
  # Returns parameters required to re-invoke vocabulary test
  def to_session_params
    return { 
      :tense_id => @tense.id,
      :limit => @limit,
      :current => @current,
      :test => @test.collect { |t| t.class == Fixnum ? t : t.first.id }
    }
  end
  
  # Returns json for web service calls
  def as_json(options = {})
    {
      :conjugation_test => {
        :tense => { :id => @tense.id, :name => @tense.name },
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
    xml.conjugation_test do
      xml.tense do 
        xml.tag!(:id, @tense.id)
        xml.tag!(:name, @tense.name)
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
  
  
  private

    # Removes verbs with incomplete conjugations from array
    def clean_verb_selection(verbs, tense_id)
      clean = []
      verbs.each do |verb|
        begin
          verb.conjugate_all(tense_id)
          clean << verb
        rescue
        end
      end
      return clean
    end
    
    # Steps common to both list and param based tags
    def setup_common_options(options)
      if options.key?(:tense_id)
        @tense = ConjugationTime.find(options[:tense_id])
        raise(ActiveRecord::RecordNotFound, "Given tense not found. Probably either a typ-o or unsupported tense.") unless @tense
        @limit = options[:limit].to_i if options.key?(:limit)
      else
        raise(ArgumentError, "Missing options. :tense_id is required at minimum.")
      end
    end
end