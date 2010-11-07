class WikiPage < ActiveRecord::Base
  
  # Import irwi features
  acts_as_wiki_page
  acts_as_taggable
  
  # Associations
  belongs_to :language
  
  # Show preview of page content
  def preview
    content[0..120]
  end
  
  # Return updates for timline
  def updates_for_timeline
     Status[
       :id => id,
       :text => "added the new page \"#{title}\"",
       :created_at => created_at,
       :url => "http://#{HOST}/wiki/#{path}",
       :user => creator.to_hash
     ]
  end
end