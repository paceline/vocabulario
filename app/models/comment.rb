class Comment < ActiveRecord::Base
  
  # Associations
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  
  # Features
  acts_as_textiled :text
  
  # Return updates for timline
  def updates_for_timeline
     Status[
       :id => id,
       :text => "commented on the #{commentable_type.downcase} \"#{commentable.word}\"",
       :created_at => created_at,
       :url => "http://#{::Rails.configuration.action_mailer.default_url_options[:host]}/#{commentable_type.pluralize.downcase}/#{commentable.permalink}",
       :user => (user ? user.to_hash : "")
     ]
  end
  
end
