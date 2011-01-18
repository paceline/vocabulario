class Rule < ActiveRecord::Base
  
  # Associations
  has_many :patterns_rules
  has_many :patterns, :through => :patterns_rules
  
  # Validations
  validates :name, :presence => true
  validates :find, :presence => true, :uniqueness => {:scope => 'replace', :message => 'already exists in database'}
  validates :replace, :presence => true, :uniqueness => {:scope => 'find', :message => 'already exists in database'}
  
  # Additional attributes
  attr_accessor :save_as_new
  
  # Searches for find pattern and replaces with replace text
  def find_and_replace(text)
    modified = if find.first == '/' && find.last == '/'
        text.gsub Regexp.new(find.gsub '/', ''), replace
      else
        text.gsub find, replace
      end
    modified == text ? nil : modified
  end
  
  # Shorthand for patterns.empty?
  def has_patterns?
    !patterns.empty?
  end
  
end
