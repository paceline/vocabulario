class Person < ActiveRecord::Base
  # Features
  SUPPORTED_PRONOUNS = ['personal','reflexive']
  
  # Associations
  belongs_to :language
  
  # Validations
  validates_uniqueness_of :pronoun, :scope => 'language_id', :message => 'already exists for this language. Please edit the existing one instead.'
  
  # Returns current set as an array
  def set_as_list
    [ first_person_singular, second_person_singular, third_person_singular, first_person_plural, second_person_plural, third_person_plural ]
  end
  
end
