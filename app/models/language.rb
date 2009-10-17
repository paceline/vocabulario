class Language < Vocabulary
  
  # Associations - Determine scores for every lanugage
  has_many :scores_from, :foreign_key => 'language_from_id', :class_name => 'Score', :dependent => :delete_all
  has_many :scores_to, :foreign_key => 'language_to_id', :class_name => 'Score', :dependent => :delete_all
  
  # Associations - Times for conjugations
  has_many :conjugation_times, :order => 'name', :dependent => :delete_all
  has_many :people
  
  # Associations - Determine vocabularies for every lanugage
  has_many :vocabularies, :foreign_key => 'language_id', :class_name => 'Vocabulary', :dependent => :delete_all
  
  
  # Return languages currently supported
  def self.list(conditions = "")
    return conditions.empty? ? find(:all, :order => 'word') : find(:all, :conditions => conditions, :order => 'word') 
  end
  
  # Get all tags for current language
  def tags_for_language
    return Tag.find(:all, :joins => 'LEFT JOIN taggings ON taggings.tag_id = tags.id LEFT JOIN vocabularies ON taggings.taggable_id = vocabularies.id', :conditions => ['vocabularies.language_id = ?',self.id], :group => 'tags.id', :order => 'tags.name')
  end

end