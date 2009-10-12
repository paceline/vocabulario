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
  
  def admin_options(vocabulary = nil)
    grouped_options = [['Add',
            [vocabulary ? ['New conjugation', new_vocabulary_conjugation_path(vocabulary)] : ['New conjugation', new_conjugation_path],
            ['New language', new_vocabulary_path(:type => 'Language')],
            ['New set of pronouns', new_person_path],
            ['New tense', new_conjugation_time_path]]
          ]]
    if vocabulary && !vocabulary.new_record?
      grouped_options[0][1] << ['New translation', edit_vocabulary_path(vocabulary)]
      grouped_options << ['Copy', [['Apply tags to translations', apply_tags_vocabulary_path(vocabulary)], ['Apply type to translations',apply_type_vocabulary_path(vocabulary)]]]
      grouped_options << ['Delete', [['Delete vocabulary',vocabulary_path(vocabulary)]]]
    end
    grouped_options[0][1] << ['New vocabulary', new_vocabulary_path]
    grouped_options[0][1] << ['Import vocabularies', import_vocabularies_path]
    
    grouped_options_for_select(grouped_options)
  end

end