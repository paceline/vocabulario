module VocabulariesHelper
 
  def languages_for_translation(translation)
    return Language.list("id != #{translation.language_id}").collect {|p| [ p.word, p.id ] }
  end
  
  def apply_transformations(rule, vocabulary)
    tense = ConjugationTime.find(:first, :conditions => ['language_id = ?',vocabulary.language.id])
    pattern = vocabulary.conjugations.find(:first, :conditions => ['conjugation_time_id = ?',tense.id])
    output = vocabulary.word.mb_chars
    vocabulary.transformations.each do |t|
      return output if t == rule
      output = t.class == ReplaceEnding ? t.execute(vocabulary, output, pattern.send(:first_person_singular)) : t.execute(vocabulary, output, :first_person_singular)
    end
  end
  
  def set_link_class(action)
    return @current_action == 'index' && action == 'live_search' || @current_action == action ? "tab_link active" : "tab_link"
  end
   
end
