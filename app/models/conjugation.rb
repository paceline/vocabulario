class Conjugation < ActiveRecord::Base
  
  # Associations
  belongs_to :conjugation_time
  has_and_belongs_to_many :verbs
  
  # Validations
  validates_presence_of :conjugation_time_id,	:name, :first_person_singular, :second_person_singular, :third_person_singular, :first_person_plural, :second_person_plural, :third_person_plural
  
  def regular_or_irregular
    self.regular? ? "regular" : "irregular"
  end
  
end
