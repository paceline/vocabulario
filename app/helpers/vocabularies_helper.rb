module VocabulariesHelper
  
  def vocabulary_links
    links = Language.list.collect { |item| link_to(item.name, vocabularies_by_language_path(item.permalink)) }
    return links.join(' | ')
  end
  
  def languages_for_translation(translation)
    return Language.list("id != #{translation.language_id}").collect {|p| [ p.word, p.id ] }
  end
   
end
