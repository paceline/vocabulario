class Language < Vocabulary
  
  # Associations - Determine scores for every lanugage
  has_many :scores_from, :foreign_key => 'language_from_id', :class_name => 'Score', :dependent => :delete_all
  has_many :scores_to, :foreign_key => 'language_to_id', :class_name => 'Score', :dependent => :delete_all
  
  # Associations - Times for conjugations
  has_many :conjugation_times, :order => 'name', :dependent => :delete_all
  has_many :people
  
  # Associations - Determine vocabularies for every lanugage
  has_many :nouns, :foreign_key => 'language_id', :class_name => 'Noun', :dependent => :delete_all, :order => 'word'
  has_many :verbs, :foreign_key => 'language_id', :class_name => 'Verb', :dependent => :delete_all, :order => 'word'
  has_many :vocabularies, :foreign_key => 'language_id', :class_name => 'Vocabulary', :dependent => :delete_all, :order => 'word'
  
  # Determine pronouns
  def self.get_methods_for_pronouns
    Person::SUPPORTED_PRONOUNS.each do |type|
      define_method "#{type}_pronouns" do
        people.find :first, :conditions => { :pronoun => type }
      end
    end
  end
  get_methods_for_pronouns
  
  # Return languages currently supported
  def self.list(conditions = "")
    return conditions.empty? ? find(:all, :order => 'word') : find(:all, :conditions => conditions, :order => 'word') 
  end
  
  # Get all tags for current language
  def tags_for_language
    return Tag.find(:all, :joins => 'LEFT JOIN taggings ON taggings.tag_id = tags.id LEFT JOIN vocabularies ON taggings.taggable_id = vocabularies.id', :conditions => ['vocabularies.language_id = ?',self.id], :group => 'tags.id', :order => 'tags.name')
  end
  
  # Get only vocabularies with translations to this language
  def vocabularies_with_translation_to(to)
    vocabularies.find(:all,
      :from => 'vocabularies, translations',
      :conditions => "(translations.vocabulary1_id = vocabularies.id OR translations.vocabulary2_id = vocabularies.id) AND (translations.vocabulary1_id IN (SELECT vocabularies.id FROM vocabularies WHERE vocabularies.language_id = #{to.id}) OR translations.vocabulary2_id IN (SELECT vocabularies.id FROM vocabularies WHERE vocabularies.language_id = #{to.id}))"
    )
  end

end