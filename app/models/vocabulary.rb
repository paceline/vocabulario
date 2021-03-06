class Vocabulary < ActiveRecord::Base
  
  # Features
  acts_as_taggable
  permalink :word
  attr_accessor :copy_tags
  cattr_reader :per_page
  @@per_page = 250
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
  has_many :translations, :class_name => 'Vocabulary', :finder_sql => proc { "SELECT vocabularies.* FROM vocabularies LEFT JOIN translations ON (translations.vocabulary1_id = vocabularies.id OR translations.vocabulary2_id = vocabularies.id) WHERE (translations.vocabulary1_id = #{id} OR translations.vocabulary2_id = #{id}) AND vocabularies.id != #{id} ORDER BY vocabularies.word" } do
    def all(to = nil)
      in_clause = self.collect { |v| v.id } << proxy_owner.id
      Vocabulary.select('DISTINCT vocabularies.*').joins("LEFT JOIN translations ON (translations.vocabulary1_id = vocabularies.id OR translations.vocabulary2_id = vocabularies.id)").where("(translations.vocabulary1_id IN ('#{in_clause.join("','")}') OR translations.vocabulary2_id IN ('#{in_clause.join("','")}')) AND vocabularies.id != #{proxy_owner.id}#{to ? " AND vocabularies.language_id = #{to}" : ""}").order("vocabularies.word")
    end
  end 
  has_many :vocabulary_lists
  has_many :lists, :through => :vocabulary_lists
  
  # Validations
  validates_inclusion_of :type, :in => TYPES, :message => "{{value}} is not a supported vocabulary type"
  validates_presence_of :language_id, :word
  validates_uniqueness_of :word, :scope => ['language_id','gender'], :message => 'already exists in database'
  
  # Hooks
  after_initialize :apply_user_defaults
  default_scope order('`vocabularies`.`word`')
  
  # Check for untagged vocabularies FIMXE - Wonder if there's a better way to do this, jus couldn't get count to work
  def self.exist_untagged?
    !find(:all, :joins => 'LEFT JOIN taggings ON taggings.taggable_id = vocabularies.id', :having => 'COUNT(taggings.id) = 0').blank?
  end
  
  # Quick way to determine type of vocabulary
  TYPES[0..TYPES.size-2].each do |type|
    define_method "#{type.downcase}?" do
      self.class.to_s == type
    end
  end
  
  # Count self grouped by language
  def self.count_by_language
    with_exclusive_scope { count(:include => 'language', :group => 'languages_vocabularies.permalink', :order => 'count_id DESC') }
  end
  
  # Imports csv string
  def self.import(data, language, user, tags = [], new_tags = [])
    temp = new({ :word => data, :user_id => user.id })
    temp.language = language.class == String ? Language.find(language) : language
    vocabulary = find_by_word_and_language_id(temp.name, temp.language_id) || temp
    vocabulary.tag_list = (vocabulary.tag_list + tags).uniq unless tags.blank?
    vocabulary.tag_list = (vocabulary.tag_list + new_tags.split(',')).uniq unless new_tags.blank?
    vocabulary.save    
    return vocabulary
  end
  
  # Searches for vocabulary
  def self.search_for(term)
    input = term.split(':')
    if input.size > 1
      case 
        when input[0].strip.match(/^translate/) 
          return where(['word LIKE ?',"%#{input[1].strip}%"]).collect { |w| w.translations.all }.flatten.uniq
        when input[0].strip.capitalize.match(Regexp.new("^(#{Language.list.collect { |l| l.name }.join('|')})"))
          return where(['word LIKE ? AND language_id = ?', "%#{input[1].strip}%", Language.where(["permalink = ?", input[0].strip.downcase]).first.id])
        when input[0].strip.capitalize.match(Regexp.new("^(#{TYPES[0..TYPES.size-2].join('|')})"))
          return where(['word LIKE ? AND type = ?', "%#{input[1].strip}%", input[0].strip.capitalize])
        else
          tag = Tag.find_by_name(input[0].strip)
          return includes(:taggings).where(['word LIKE ? AND taggings.tag_id = ?', "%#{input[1].strip}%", tag.id]) if tag
      end
    else
      return where(['word LIKE ?',"%#{term}%"])
    end
  end
  
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
    translations.each do |translation|
      translation.tag_list = (translation.tag_list + self.tag_list).uniq
      translation.save
    end
  end
  
  # Copy type to translations
  def apply_type_to_translations
    translations.each do |translation|
      translation.patterns.clear unless translation.patterns.blank?
      translation.kind = self.kind
      translation.save
    end
  end
  
  # Set method for re-casting vocabulary type
  def kind=(value)
    self[:type] = value == "Vocabulary" ? nil : value
  end

  # Get method for vocabulary type
  def kind
    return self[:type] ? self[:type] : "Vocabulary"
  end
  
  # Return true if gender is set
  def gender?
    gender && gender != 'N/A'
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
    read_attribute(:word)
  end
  
  # Alias for word
  def name=(value)
    write_attribute(:word, value)
  end
  
  # Translations for inclusion in parameter-less to_json/to_xml calls
  def translation
    result = List.current ? translations.all(List.current.language_to.id) : self.translations.all
    result.collect { |r| { :id => r.id, :word => r.word, :language => { :id => r.language.id, :word => r.language.word } } }
  end
  
  private
    def apply_user_defaults
      if new_record? && user
        self.language_id = language_id == user.default_from ? user.default_to : user.default_from
      end
    end

end
