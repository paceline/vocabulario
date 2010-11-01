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
  
end