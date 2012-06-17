class Comment < ActiveRecord::Base
  
  # Associations
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  
end
