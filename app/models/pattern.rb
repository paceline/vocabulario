class Pattern < ActiveRecord::Base
  
  # Associations
  belongs_to :conjugation_time
  has_one :language, :through => :conjugation_time
  has_many :patterns_rules, :dependent => :destroy
  has_many :rules, :through => :patterns_rules, :order => 'position'
  has_and_belongs_to_many :verbs, :order => 'word'
  
  # Validations
  validates :name, :person, :presence => true 
  
  # Conjugate based on tense, person and associated rules
  def conjugate(verb)
    rules.each do |rule|
      verb = rule.find_and_replace(verb)
      return nil unless verb
    end
    return verb
  end
  
  # Browse and determine fitting verbs
  def auto_detect_verbs
    matched = verbs.blank? ? language.verbs.find(:all).collect { |verb| verb if conjugate(verb.word) } : language.verbs.find(:all, :conditions => "id NOT IN (#{verbs.collect { |v| v.id }.join(',')})").collect { |verb| verb if conjugate(verb.word) }
    matched.reject { |verb| verb == nil }
  end
  
  # Override destroy to clean-up dependent rules
  def destroy
    rules.collect { |rule| rule.destroy unless rule.patterns.size > 1 }
    super
  end
  
end
