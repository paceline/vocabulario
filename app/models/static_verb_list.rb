class StaticVerbList < List
  
  # Features
  has_permalink :name, :update => true
  
  # Get the ids of vocabularies on list
  def ids
    vocabulary_lists.collect { |i| i.vocabulary_id.to_s }
  end
  
  def add_vocabulary(vocabulary, position)
    vocabulary.add_to_list(self.id, position) if vocabulary.verb?
  end
  
end