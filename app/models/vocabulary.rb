class Vocabulary < ActiveRecord::Base
  
  # Features
  acts_as_taggable
  has_permalink :word, :update => true
  cattr_reader :per_page
  @@per_page = 150
  TYPES = ['Language','Noun','Verb',nil]
  
  # Associations - Determine language for every vocabulary
  belongs_to :language, :foreign_key => 'language_id', :class_name => 'Vocabulary'
  
  # Associations - Determines user who addess vocabulary
  belongs_to :user
  
  # Associations - Determine translations (to and from) for vocabulary. relations_to/from reference join model translation
  has_many :relations_to, :foreign_key => 'vocabulary1_id',  :class_name => 'Translation'
  has_many :relations_from, :foreign_key => 'vocabulary2_id', :class_name => 'Translation'
  has_many :transformations, :order => 'position'
  has_many :translation_to, :through => :relations_to, :source => :vocabulary2
  has_many :translation_from, :through => :relations_from, :source => :vocabulary1
  has_many :vocabulary_lists
  has_many :lists, :through => :vocabulary_lists
  
  # Validations
  validates_inclusion_of :type, :in => TYPES, :message => "{{value}} is not a supported vocabulary type"
  validates_presence_of :word, :language_id
  validates_uniqueness_of :word, :scope => ['language_id','gender'], :message => 'already exists in database'
  
  # Copy tags to translations
  def apply_tags_to_translations
    self.translations.each do |translation|
      translation.tag_list = (translation.tag_list + self.tag_list).uniq
      translation.save
    end
  end
  
  # Copy type to translations
  def apply_type_to_translations
    self.translations.each do |translation|
      translation.conjugations.clear unless translation.conjugations.blank?
      translation.class_type = self.class_type
      translation.save
    end
  end
  
  # Set method for re-casting vocabulary type
  def class_type=(value)
    self[:type] = value == "Vocabulary" ? nil : value
  end

  # Get method for vocabulary type
  def class_type
    return self[:type] ? self[:type] : "Vocabulary"
  end
  
  # Stub for conjugation realtionship
  def conjugations
    nil
  end
  
  # Make sure no dead references are left
  def destroy
    Translation.delete_all(['vocabulary1_id = ? OR vocabulary2_id = ?', self.id, self.id])
    super
  end
  
  # Alias for word
  def name
    return word
  end
  
  # Imports csv string
  def import(user, tags)
    self.user = user
    self.tag_list = (self.tag_list + tags).uniq unless tags.blank?
  end
  
  # Gather all translations (to and from) for given vocabulary id
  def translations(to = nil)
    if to
      return self.translation_to.find(:all, :conditions => ['language_id = ?', to]) + self.translation_from.find(:all, :conditions => ['language_id = ?', to])
    end
    return self.translation_to + self.translation_from
  end
  
  # Check for untagged vocabularies FIMXE - Wonder if there's a better way to do this, jus couldn't get count to work
  def self.exist_untagged?
    !find(:all, :joins => 'LEFT JOIN taggings ON taggings.taggable_id = vocabularies.id', :having => 'COUNT(taggings.id) = 0').blank?
  end
  
  # Retrun TYPES in a user-friendly way
  def self.supported_types
    types = []
    TYPES.each do |t|
      type = t.blank? ? ['Other', t] : [t, t]
      types << type
    end
    return types
  end

end
