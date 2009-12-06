class List < ActiveRecord::Base
  
  # Features
  acts_as_taggable
  attr_reader :max_translations
  has_permalink :name, :update => true
  TIMEUNITS = ['days','weeks','months']
  
  # Associations
  belongs_to :language_from, :class_name => 'Language'
  belongs_to :language_to, :class_name => 'Language'
  belongs_to :user
  has_many :vocabulary_lists, :dependent => :destroy, :order => :position
  has_many :vocabularies, :through => :vocabulary_lists, :order => :position
  
  # Validations
  validates_presence_of :user_id, :language_from_id, :language_to_id, :name
  
  
  # Find public lists
  def self.find_public(user = nil)
    if user
      find(:all, :conditions => ['public = ? OR user_id = ?', true, user.id])
    else
      find(:all, :conditions => ['public = ?', true])
    end
  end
  
  # Quick way to determine type of list
  def self.identify_methods_for_subclasses(*args)
    attr_accessor *args
    args.each do |type|
      define_method "#{type}?" do
        self.class.to_s == "#{type.to_s.capitalize}List"
      end
    end
  end
  identify_methods_for_subclasses :dynamic, :static
  
  # Checks whether list is public or private
  def public?
    public ? "public" : "private"
  end
  
  # Returns list size
  def size
    vocabularies.size
  end
  
  # "Reverses" list
  def vocabularies_to_translations
    new_list = []
    vocabularies.each do |v|
      translations = v.translations(language_to_id)
      new_list << translations[rand(translations.size-1)]
    end
    return new_list
  end

end
