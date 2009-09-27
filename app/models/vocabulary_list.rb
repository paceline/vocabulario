class VocabularyList < ActiveRecord::Base
  
  # Features
  acts_as_list :scope => :list
  
  # Associations
  belongs_to :list
  belongs_to :vocabulary
  
  # Validations
  validates_uniqueness_of :vocabulary_id, :scope => :list_id
  
end
