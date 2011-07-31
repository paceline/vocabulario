class WikiPage < ActiveRecord::Base

  # Import irwi features
  acts_as_wiki_page
  acts_as_taggable

  # Associations
  belongs_to :language
  
  # Get most popular language
  def guess_second_language
    if language
      vocabularies = "(#{Vocabulary.find_tagged_with(tags, :match_all => false, :conditions => "language_id = #{language_id}").collect { |v| v.id }.join(",")})"
      Vocabulary.first(:conditions => "id IN (SELECT vocabularies.language_id FROM vocabularies LEFT JOIN translations ON (vocabulary1_id = vocabularies.id OR vocabulary1_id = vocabularies.id) WHERE (vocabulary1_id IN #{vocabularies} OR vocabulary2_id IN #{vocabularies}) GROUP BY vocabularies.language_id ORDER BY COUNT(*))")
    else
      return nil
    end
  end
  
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
      :url => "http://#{::Rails.configuration.action_mailer.default_url_options[:host]}/wiki/#{path}",
      :user => creator.to_hash
    ]
  end

end
