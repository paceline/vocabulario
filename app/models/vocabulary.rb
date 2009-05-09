class Vocabulary < ActiveRecord::Base
  
  # Features
  acts_as_taggable
  has_permalink :word, :update => true
  cattr_reader :per_page
  @@per_page = 100
  
  # Associations - Determine language for every vocabulary
  belongs_to :language, :foreign_key => 'language_id', :class_name => 'Vocabulary'
  
  # Associations - Determine translations (to and from) for vocabulary. relations_to/from reference join model translation
  has_many :relations_to, :foreign_key => 'vocabulary1_id',  :class_name => 'Translation'
  has_many :relations_from, :foreign_key => 'vocabulary2_id', :class_name => 'Translation'
  has_many :translation_to, :through => :relations_to, :source => :vocabulary2
  has_many :translation_from, :through => :relations_from, :source => :vocabulary1
  
  # Validations
  validates_uniqueness_of :word, :scope => 'language_id', :message => 'already exists in database'
  
  # Copy tags to translations
  def apply_tags_to_translations
    self.translations.each do |translation|
      translation.tag_list = (translation.tag_list + self.tag_list).uniq
      translation.save
    end
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
  def import(csv, tags)
    word = csv.split(', ')
    self.word = word[0]
    self.gender = word[1] if word.size > 1
    self.tag_list = tags
  end
  
  # Gather all translations (to and from) for given vocabulary id
  def translations(to = nil)
    if to
      return self.translation_to.find(:all, :conditions => ['language_id = ?', to]) + self.translation_from.find(:all, :conditions => ['language_id = ?', to])
    end
    return self.translation_to + self.translation_from
  end
  
end
