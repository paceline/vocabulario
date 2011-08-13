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

  # Return updates for timline
  def updates_for_timeline
    Status[
      :id => id,
      :text => "added the new page \"#{title}\"",
      :created_at => created_at,
      :url => "http://#{::Rails.configuration.action_mailer.default_url_options[:host]}/wiki/#{path}",
      :user => creator.to_hash
    ]
  end

end
