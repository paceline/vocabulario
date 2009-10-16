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
  def verbs_tagged_with(tags)
    return Verb.find_by_sql("SELECT vocabularies.* FROM vocabularies, conjugation_times, conjugations, conjugations_verbs, taggings WHERE vocabularies.type = 'Verb' AND conjugation_times.id = conjugations.id AND conjugations.id = conjugations_verbs.conjugation_id AND conjugations_verbs.verb_id = vocabularies.id AND conjugation_times.id = #{id} AND taggings.tag_id IN (#{tags}) GROUP BY vocabularies.id")
  end
  
end
