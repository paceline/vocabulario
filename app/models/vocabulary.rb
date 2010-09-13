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
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :relations_to, :foreign_key => 'vocabulary1_id',  :class_name => 'Translation'
  has_many :relations_from, :foreign_key => 'vocabulary2_id', :class_name => 'Translation'
  has_many :translation_to, :through => :relations_to, :source => :vocabulary2
  has_many :translation_from, :through => :relations_from, :source => :vocabulary1
  has_many :vocabulary_lists
  has_many :lists, :through => :vocabulary_lists
  
  # Validations
  validates_inclusion_of :type, :in => TYPES, :message => "{{value}} is not a supported vocabulary type"
  validates_presence_of :word, :language_id
  validates_uniqueness_of :word, :scope => ['language_id','gender'], :message => 'already exists in database'
  
  
  # Check for untagged vocabularies FIMXE - Wonder if there's a better way to do this, jus couldn't get count to work
  def self.exist_untagged?
    !find(:all, :joins => 'LEFT JOIN taggings ON taggings.taggable_id = vocabularies.id', :having => 'COUNT(taggings.id) = 0').blank?
  end
  
  # Quick way to determine type of vocabulary
  def self.identify_methods_for_subclasses
    TYPES[0..TYPES.size-2].each do |type|
      define_method "#{type.downcase}?" do
        self.class.to_s == type
      end
    end
  end
  identify_methods_for_subclasses
  
  # Adds vocabulary to list
  def add_to_list(list_id, position = 1)
    lister = self.vocabulary_lists.build({ :list_id => list_id })
    if lister.valid? && lister.errors.empty?
      lister.save
      lister.insert_at(position)
      return true
    end
    return false
  end
  
  # Removes vocabulary from list
  def remove_from_list(list_id)
    list = VocabularyList.find(:first, :conditions => ['list_id = ? AND vocabulary_id = ?', list_id, self.id])
    list.remove_from_list
    list.destroy
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
      translation.patterns.clear unless translation.patterns.blank?
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
  def patterns
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
  def import(user, tags, new_tags)
    self.user = user if new_record?
    self.tag_list = (self.tag_list + tags).uniq unless tags.blank?
    self.tag_list = (self.tag_list + new_tags.split(',')).uniq unless new_tags.blank?
  end
  
  # Gather all translations (to and from) for given vocabulary id
  def translations(to = nil)
    translations = all_translations.sort { |x,y| x.word.downcase <=> y.word.downcase }
    return to ? translations.delete_if {|t| t.language_id != to} : translations
  end
  
  # Return updates for timline
  def updates_for_timeline
     Status[
       :id => id,
       :text => "added the new #{language.word} vocabulary \"#{word}\"",
       :created_at => created_at,
       :url => "http://#{HOST}/vocabularies/#{permalink}",
       :user => user.to_hash
     ]
  end
  
  protected
    def all_translations(word = self, translations = [])
      new_translations = word.translation_to.find(:all, :conditions => ['language_id != ?', self.language_id]) + word.translation_from.find(:all, :conditions => ['language_id != ?', self.language_id])
      new_translations -= (translations & new_translations)
      translations += new_translations
      new_translations.each do |t|
        translations = all_translations(t, translations)
      end
      return translations
    end

end
