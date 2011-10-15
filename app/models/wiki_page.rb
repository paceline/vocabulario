require 'sanitize'

class WikiPage < ActiveRecord::Base

  # Import irwi features
  acts_as_wiki_page
  acts_as_taggable

  # Associations
  belongs_to :language
  
  # Show preview of page content
  def preview
    Sanitize.clean(RedCloth.new(content).to_html.gsub('[[','').gsub(']]',''))[0..200] + '...'
  end

end
