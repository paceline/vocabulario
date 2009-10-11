class DynamicList < List
  
  # Returns vocabularies associated with list
  def vocabularies
    Vocabulary.find_tagged_with(tag_list, :conditions => ['language_id = ?', language_from])
  end

end