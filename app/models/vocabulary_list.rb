class VocabularyList < ActiveRecord::Base
  
  # Features
  acts_as_list :scope => :list
  
  # Associations
  belongs_to :list
  belongs_to :vocabulary
  
  # Validations
  validates :vocabulary_id, :presence => true, :uniqueness => { :scope => :list_id }
  
end
