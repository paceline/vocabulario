class ConjugationTime < ActiveRecord::Base
  
  # Associations
  belongs_to :language
  has_many :patterns, :order => 'name'
  has_many :verbs, :finder_sql => 'SELECT DISTINCT vocabularies.* FROM vocabularies LEFT JOIN patterns_verbs ON patterns_verbs.verb_id = vocabularies.id LEFT JOIN patterns ON patterns.id = patterns_verbs.pattern_id LEFT JOIN conjugation_times ON conjugation_times.id = patterns.conjugation_time_id WHERE conjugation_times.id = #{id}'
  
  # Validations
  validates :language_id, :presence => true
  validates :name, :presence => true, :uniqueness => {:scope => 'language_id', :message => 'already exists in database'}
  
  # Features
  has_permalink :name, :update => true
  
  # Get verbs with certain tags only
  def verbs_tagged_with(all_or_any, tags)
    Verb.find_tagged_with(
      tags,
      :match_all => all_or_any,
      :conditions => "conjugation_times.id = #{id}",
      :joins => "LEFT JOIN patterns_verbs ON patterns_verbs.verb_id = vocabularies.id LEFT JOIN patterns ON patterns.id = patterns_verbs.pattern_id LEFT JOIN conjugation_times ON conjugation_times.id = patterns.conjugation_time_id"
    )
  end
  
  # Make current tense available 
  def self.current
    Thread.current[:conjugation_time]
  end
  def self.current=(tense)
    Thread.current[:conjugation_time] = tense
  end
  
end
