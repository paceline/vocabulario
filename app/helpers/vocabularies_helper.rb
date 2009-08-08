module VocabulariesHelper
  
  # Returns links for by_language
  def language_links
    links = Language.list.collect { |item| link_to(item.name, vocabularies_by_language_path(item.permalink)) }
    return links.join(' | ')
  end
   
  # Returns links for by_type 
  def type_links
    links = []
    Vocabulary::TYPES.each do |type|
      if type
        links << link_to(type, vocabularies_by_type_path(type))
      else
        links << link_to('Other', vocabularies_by_type_path('other'))
      end
    end
    return links.join(' | ')
  end
  
  def languages_for_translation(translation)
    return Language.list("id != #{translation.language_id}").collect {|p| [ p.word, p.id ] }
  end
  
  def apply_transformations(rule, vocabulary)
    tense = ConjugationTime.find(:first, :conditions => ['language_id = ?',vocabulary.language.id])
    pattern = vocabulary.conjugations.find(:first, :conditions => ['conjugation_time_id = ?',tense.id])
    output = vocabulary.word
    vocabulary.transformations.each do |t|
      return output if t == rule
      output = t.class == Replace ? t.execute(vocabulary, output, pattern.send(:first_person_singular)) : t.execute(vocabulary, output, :first_person_singular)
    end
  end
   
end
