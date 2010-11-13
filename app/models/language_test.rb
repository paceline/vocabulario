class LanguageTest
  
  # Features
  attr_accessor :current
  attr_reader :limit, :tags
  LIMITS = [5,10,25,50,75,100,'all']
  
  # Initialize new test
  def initialize(*args)
    options = args.extract_options!
    args.size == 1 ? setup_based_on_list(args.first, options) : setup_based_on_params(options)
  end
  
  # Generate test questions
  def generate_test(words = nil)
    @limit = @limit && @limit <= words.size ? @limit : words.size
    @test = []
    @current = 0
    generate_test_order(words)
    return true
  end
  
  # (Re-)generate test questions
  def restore_test(current, test)
    @current = current
    @test = test.collect { |i| i.to_i }
  end
  
  # Returns question for current position
  def current_question
    load_current_question
    return @test[@current][0]
  end
  
  # Reader for number of questions in test (typically = limit, except when not enough questions in pool)
  def size
    return @test.size
  end
  
  # Returns true if over limit
  def continue?
    @test.size > @current
  end
  
  # Returns question for given position
  def current=(position)
    @current = position
    return @current
  end
  
  # Returns true if no vocabularies were found
  def empty?
    @test.size == 0
  end
  
  protected
    # Generates random order of test questions w/ respective results
    def generate_test_order(words, i=0)
      if i < @limit
        next_word = words.delete_at(rand(words.size-1))
        answers = self.class == VocabularyTest ? next_word.translations(@to.id) : next_word.conjugate_all(@tense.id)
        @test << next_word.id unless answers.empty?
        generate_test_order(words, i+=1)
      end
    end
    
    # Loads current questions
    def load_current_question
      if @test[@current].class == Fixnum
        word = Vocabulary.find @test[@current]
        @test[@current] = [ word, (self.class == VocabularyTest ? word.translations(@to.id) : word.conjugate_all(@tense.id)) ]
      end
    end  
end