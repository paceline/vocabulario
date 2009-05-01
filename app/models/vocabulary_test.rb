class VocabularyTest
  
  # Readers for member variables
  attr_reader :current, :from, :to, :limit
  
  # Initialize new vocabulary test
  def initialize(*args)
    options = args.extract_options!
    if options.key?(:to) && options.key?(:from)
      @from = Vocabulary.find(options[:from])
      @to = Vocabulary.find(options[:to])
      raise(ActiveRecord::RecordNotFound, "At least one of the languages not found. Probably either a typ-o or unsupported language.") unless @to && @from
      @limit = options[:limit].to_i if options.key?(:limit)
      @tags = options[:tags].join(',') if options.key?(:tags)
      generate_test
      super
    else
      raise(ArgumentError, "Missing options. :to and :from are required at minimum.")
    end
  end
  
  # (Re-)generate test questions
  def generate_test
    words = @tags ? @from.vocabularies.find(:all, :conditions => "taggings.tag_id IN (#{@tags})", :include => [ :taggings ]) : @from.vocabularies
    @limit = @limit <= words.size ? @limit : words.size
    @test = []
    @current = 0
    generate_test_order(words)
    return true
  end
  
  # Define available limits
  def self.limits
    return [2,5,10,25,50,75,100]
  end 
  
  # Reader for number of questions in test (typically = limit, except when not enough questions in pool)
  def size
    return @test.size
  end
  
  # Returns question for current position
  def current_question
    return @test[@current][0]
  end
  
  # Returns true if over limit
  def continue?
    return @test.size <= @current ? false : true
  end
  
  # Returns question for given position
  def current=(position)
    @current = position
    return @current
  end
  
  # Returns result for current question (answer true/false)
  def result_for(response = "")
    return correct_results.include?(response)
  end
  
  # Returns set of correct results for current question
  def correct_results
    return @test[@current][1].collect { |result| result.word }
  end
  
  protected
    # Generates random order of test questions w/ respective results
    def generate_test_order(words, i=0)
      if i < @limit
        next_word = words.delete_at(rand(words.size-1))
        translations = next_word.translations(@to.id)
        @test << [ next_word, translations ] unless translations.empty?
        generate_test_order(words, i+=1)
      end
    end
  
end