class Pattern < ActiveRecord::Base
  
  # Associations
  belongs_to :conjugation_time
  has_and_belongs_to_many :verbs
  has_many :patterns_rules
  has_many :rules, :through => :patterns_rules, :order => 'position'
  
  # Validations
  validates_presence_of :name, :person
  
  # Conjugate based on tense, person and associated rules
  def conjugate(verb)
    rules.each do |rule|
      verb = rule.find_and_replace(verb)
      return nil unless verb
    end
    return verb
  end
  
end
