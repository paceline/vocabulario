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
  has_many :vocabulary_lists, :dependent => :destroy
  has_many :vocabularies, :through => :vocabulary_lists, :order => [:position,:word]
  
  # Validations
  validates :user_id, :language_from_id, :name, :presence => true
  
  # Hooks
  after_initialize :apply_user_defaults
  default_scope order('`lists`.`name`')
  
  # Find public lists
  def self.find_accessible(user = nil)
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
        if type.to_s.starts_with?('v')
          self.class.to_s.include?(type.to_s.capitalize)
        else
          self.class.to_s.starts_with?(type.to_s.capitalize)
        end
      end
    end
  end
  identify_methods_for_subclasses :smart, :static, :verb, :vocabulary
  
  def to_attribute
    self.class.to_s.underscore.downcase.to_sym
  end
  
  # Return all lists
  def self.list(conditions = "")
    return conditions.empty? ? find(:all) : find(:all, :conditions => conditions) 
  end
  
  # Check whether list is accessable to a certain user
  def accessible?(user)
    public? || self.user == user
  end
  
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
      new_list += v.translations.all(language_to_id)
    end
    return new_list.uniq
  end
  
  # Make current list available 
  def self.current
    Thread.current[:list]
  end
  def self.current=(list)
    Thread.current[:list] = list
  end
  
  private
    def apply_user_defaults
      if new_record? && user
        self.language_from_id = user.default_from
        self.language_to_id = user.default_to
      end
    end

end
