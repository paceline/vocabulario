module VocabulariesHelper
  
  def vocabulary_links
    links = Vocabulary.languages.collect { |item| link_to(item.name, vocabularies_by_language_path(item.permalink)) }
    return links.join(' | ')
  end
   
end
