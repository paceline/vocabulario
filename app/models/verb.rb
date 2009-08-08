class Verb < Vocabulary
  
  # Associations
  has_and_belongs_to_many :conjugations
  has_many :conjugation_rules
  
  # Conjugates self based on tense and person given
  def conjugate(tense_id, person)
    tense = ConjugationTime.find(tense_id)
    pattern = self.conjugations.find(:first, :conditions => ['conjugation_time_id = ?',tense.id])
    output = word
    transformations.each do |t|
      output = t.class == Replace ? t.execute(self, output, pattern.send(person)) : t.execute(self, output, person)
    end
    return output
  end
  
  # Conjugates self for first person singular through third person plural
  def conjugate_all(tense_id)
    conjugation = []
    [:first_person_singular, :second_person_singular, :third_person_singular, :first_person_plural, :second_person_plural, :third_person_plural].each do |person|
      conjugation << conjugate(tense_id, person)
    end
    return conjugation
  end
  
end