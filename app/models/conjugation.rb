class Conjugation < ActiveRecord::Base
  
  # Associations
  belongs_to :conjugation_time
  has_and_belongs_to_many :verbs
  
  def regular_or_irregular
    self.regular? ? "regular" : "irregular"
  end
  
end
