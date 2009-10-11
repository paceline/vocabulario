class VocabularyTest < LanguageTest
  
  # Readers for member variables
  attr_reader :from, :to
  
  # Initialize new vocabulary test
  def initialize(*args)
    options = args.extract_options!
    args.size == 1 ? setup_based_on_list(args.first, options[:reverse]) : setup_based_on_params(options)
  end
  
  # Setup a new vocabulary test based on a vocabulary list
  def setup_based_on_list(list_id, reverse)
    list = List.find(list_id)
    @from = reverse ? list.language_to : list.language_from
    @to = reverse ? list.language_from : list.language_to
    @limit = list.size
    @tags = list.tag_list
    generate_test(reverse ? list.vocabularies_to_translations : list.vocabularies)
  end
  
  # Setup a new vocabulary test based on params (language, tags, etc.)
  def setup_based_on_params(options)
    if options.key?(:to) && options.key?(:from) && options.key?(:limit)
      @from = Vocabulary.find(options[:from])
      @to = Vocabulary.find(options[:to])
      raise(ActiveRecord::RecordNotFound, "At least one of the languages not found. Probably either a typ-o or unsupported language.") unless @to && @from
      @limit = options[:limit].to_i if options.key?(:limit)
      @tags = options[:tags].join(',') if options.key?(:tags)
      options.key?(:current) && options.key?(:test) ? restore_test(options[:current], options[:test]) : generate_test(@tags ? @from.vocabularies.find(:all, :conditions => "taggings.tag_id IN (#{@tags})", :include => [ :taggings ]) : @from.vocabularies)
    else
      raise(ArgumentError, "Missing options. :to, :from, and :limit are required at minimum.")
    end
  end
  
  # Returns result for current question (answer true/false)
  def result_for(response = "")
    return correct_results.include?(response)
  end
  
  # Returns set of correct results for current question
  def correct_results
    return @test[@current][1].collect { |result| result.word }
  end
  
  # Returns parameters required to re-invoke vocabulary test
  def to_session_params
    return { 
      :from => @from.id,
      :to => @to.id,
      :limit => @limit,
      :current => @current,
      :test => @test.collect { |t| t.first.id }
    }
  end

end