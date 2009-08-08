class ReplacePronoun < Transformation
  
  # Executes transformation on associated vocabulary
  def execute(vocabulary, word, person)
    pronoun = vocabulary.language.people.find(:first, :conditions => "pronoun = 'reflexive'")
    return word.gsub(word[pattern_start..pattern_end],pronoun.send(person))
  end
  
end