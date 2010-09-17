class Rule < ActiveRecord::Base
  
  # Associations
  has_many :patterns_rules
  has_many :patterns, :through => :patterns_rules
  
  # Validations
  validates_presence_of :name, :find, :replace
  validates_uniqueness_of :find, :scope => 'replace', :message => 'already exists in database'
  validates_uniqueness_of :replace, :scope => 'find', :message => 'already exists in database'
  
  # Searches for find pattern and replaces with replace text
  def find_and_replace(text)
    modified = if find.first == '/' && find.last == '/'
        text.gsub Regexp.new(find.gsub '/', ''), replace
      else
        text.gsub find, replace
      end
    modified == text ? nil : modified
  end
  
end
