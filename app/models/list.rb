class List < ActiveRecord::Base
  
  # Features
  acts_as_taggable
  attr_reader :max_translations
  has_permalink :name, :update => true
  
  # Associations
  belongs_to :language_from, :class_name => 'Language'
  belongs_to :language_to, :class_name => 'Language'
  belongs_to :user
  has_many :vocabulary_lists, :dependent => :destroy, :order => :position
  has_many :vocabularies, :through => :vocabulary_lists, :order => :position
  
  # Validations
  validates_presence_of :name, :language_from_id, :language_to_id
  
  # Find public lists
  def self.find_public(user = nil)
    if user
      find(:all, :conditions => ['public = ? OR user_id = ?', true, user.id])
    else
      find(:all, :conditions => ['public = ?', true])
    end
  end
  
  # Checks whether list is public or private
  def public?
    public ? "public" : "private"
  end
  
  # Returns list size
  def size
    vocabulary_lists.size
  end

end
