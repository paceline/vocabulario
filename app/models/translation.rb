class Translation < ActiveRecord::Base
  
  # Associations - Link two vocabularies to form a translation
  belongs_to :vocabulary1, :class_name => 'Vocabulary'
  belongs_to :vocabulary2, :class_name => 'Vocabulary'
  
end
