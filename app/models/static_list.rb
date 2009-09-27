class StaticList < List
  
  # Get the ids of vocabularies on list
  def ids
    vocabulary_lists.collect { |i| i.vocabulary_id.to_s }
  end

end