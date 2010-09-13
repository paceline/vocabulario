class PatternsRule < ActiveRecord::Base
  
  # Associations
  belongs_to :pattern
  belongs_to :rule
  
  # Features
  acts_as_list :scope => :pattern
  
  
end
