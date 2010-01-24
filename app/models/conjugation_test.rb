class ConjugationTest < LanguageTest
  
  # Readers for member variables
  attr_reader :tense
  
  # Initialize new vocabulary test
  def initialize(*args)
    options = args.extract_options!
    if options.key?(:tense)
      @tense = ConjugationTime.find(options[:tense])
      raise(ActiveRecord::RecordNotFound, "Given tense not found. Probably either a typ-o or unsupported tense.") unless @tense
      @limit = options[:limit].to_i if options.key?(:limit)
      @tags = options[:tags] if options.key?(:tags)
      options.key?(:current) && options.key?(:test) ? restore_test(options[:current], options[:test]) : generate_test(@tags ? clean_verb_selection(@tense.verbs_tagged_with(Boolean(options[:all_or_any]), @tags), @tense.id) : clean_verb_selection(@tense.verbs, @tense.id))
      super
    else
      raise(ArgumentError, "Missing options. :tense is required at minimum.")
    end
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
    return @test[@current][1]
  end
  
  # Returns parameters required to re-invoke vocabulary test
  def to_session_params
    return { 
      :tense => @tense.id,
      :limit => @limit,
      :current => @current,
      :test => @test.collect { |t| t.first.id }
    }
  end
  
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
  
end