class LanguageTest
  
  # Fetaures
  attr_reader :current, :limit, :tags
  LIMITS = [5,10,25,50,75,100,'all']
  
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
    @test = []
    test.each do |test|
      word = Vocabulary.find(test)
      answers = self.class == VocabularyTest ? word.translations(@to.id) : word.conjugate_all(@tense.id)
      @test << [ word, answers ] unless answers.empty?
    end
  end
  
  # Returns question for current position
  def current_question
    return @test[@current][0]
  end
  
  # Reader for number of questions in test (typically = limit, except when not enough questions in pool)
  def size
    return @test.size
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
        @test << [ next_word, answers ] unless answers.empty?
        generate_test_order(words, i+=1)
      end
    end
  
end