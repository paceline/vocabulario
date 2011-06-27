class Verb < Vocabulary
  
  # Associations
  has_and_belongs_to_many :patterns, :order => 'person' do
    def for_tense(tense_id)
      find :all, :conditions => { :conjugation_time_id => tense_id }, :order => 'person'
    end
    def for_tense_and_person(tense_id, person)
      find :first, :conditions => { :conjugation_time_id => tense_id, :person => person }
    end
  end
  
  # Features
  has_permalink :name, :update => true
  
  # Extra Variables
  PERSONS = [:first_person_singular, :second_person_singular, :third_person_singular, :first_person_plural, :second_person_plural, :third_person_plural]
  
  # Conjugates self based on tense and person given
  def conjugate(tense_id, person)
    pattern = self.patterns.for_tense_and_person tense_id, PERSONS.index(person)
    raise(RuntimeError, "In order conjugate a verb needs both a tense and a matching pattern") unless pattern
    pattern.conjugate word
  end
  
  # Conjugates self for first person singular through third person plural
  def conjugate_all(tense_id)
    @conjugation = []
    PERSONS.each do |person|
      @conjugation << conjugate(tense_id, person)
    end
    return @conjugation
  end
  
  # Spits out conjugation as hash for json/xml output
  def conjugation_to_hash
    result = []
    pronouns = language.personal_pronouns
    if @conjugation
      0.upto(@conjugation.size-1) do |i|
        result << { "person" => pronouns.by_integer(i), "verb" => @conjugation[i] }
      end
    end
    return result
  end
  
  # Auto-detects matching patterns
  def auto_detect_patterns(tense_id)
    detected = []
    0.upto(5) do |i|
      temp = []
      Pattern.find(:all, :conditions => ['conjugation_time_id = ? AND person = ?', tense_id, i]).each do |pattern|
        temp << pattern if pattern.conjugate(word)
      end
      detected << temp
    end
    return detected.flatten.blank? ? nil : detected
  end
  
  # Manages associated pattern pool
  def update_pattern_links(tense_id, new_ids_pool)
    old_pool = patterns.for_tense tense_id
    new_pool = new_ids_pool.collect { |id| Pattern.find id }
    (old_pool - new_pool).collect { |pattern| patterns.delete pattern }
    (new_pool - old_pool).collect { |pattern| patterns << pattern }
  end
  
end