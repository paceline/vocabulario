class ConjugationTest < LanguageTest
  
  # Readers for member variables
  attr_reader :tense
  
  # Initialize new vocabulary test
  def initialize(*args)
    options = args.extract_options!
    if options.key?(:tense) && options.key?(:limit)
      @tense = ConjugationTime.find(options[:tense])
      raise(ActiveRecord::RecordNotFound, "Given tense not found. Probably either a typ-o or unsupported tense.") unless @tense
      @limit = options[:limit].to_i if options.key?(:limit)
      @tags = options[:tags].join(',') if options.key?(:tags)
      options.key?(:current) && options.key?(:test) ? restore_test(options[:current], options[:test]) : generate_test(@tags ? @tense.verbs_tagged_with(@tags) : @tense.verbs)
      super
    else
      raise(ArgumentError, "Missing options. :tense and :limit are required at minimum.")
    end
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
  
end