class ConjugationTime < ActiveRecord::Base
  
  # Associations
  belongs_to :language
  has_many :conjugations, :dependent => :delete_all, :order => 'name' do
    def regular
      find(:all, :conditions => 'regular = 1')
    end
    def irregular
      find(:all, :conditions => 'regular = 0')
    end
  end
  has_many :verbs, :finder_sql => 'SELECT vocabularies.* FROM vocabularies LEFT JOIN conjugations_verbs ON conjugations_verbs.verb_id = vocabularies.id LEFT JOIN conjugations ON conjugations.id = conjugations_verbs.conjugation_id LEFT JOIN conjugation_times ON conjugation_times.id = conjugations.conjugation_time_id WHERE conjugation_times.id = #{id}'
  
  # Validations
  validates_presence_of :language_id, :name
  validates_uniqueness_of :name, :scope => 'language_id', :message => 'already exists in database'
  
  # Get verbs with certain tags only
  def verbs_tagged_with(all_or_any, tags)
    Verb.find_tagged_with(
      tags,
      :match_all => all_or_any,
      :conditions => "conjugation_times.id = #{id}",
      :joins => "INNER JOIN conjugations_verbs ON conjugations_verbs.verb_id = vocabularies.id INNER JOIN conjugations ON conjugations.id = conjugations_verbs.conjugation_id INNER JOIN conjugation_times ON conjugation_times.id = conjugations.id"
    )
  end
  
end
