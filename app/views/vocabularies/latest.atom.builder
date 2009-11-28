atom_feed do |feed|
  feed.title "Vocabulario - Latest additions"
  feed.subtitle "The last 20 vocabularies added to Vocabulario"
  feed.updated @latest.first.updated_at
 
  for vocabulary in @latest
    next if vocabulary.updated_at.blank?
    feed.entry(vocabulary, :url => vocabulary_path(vocabulary.permalink)) do |entry|
      entry.title vocabulary.word
      entry.content vocabulary.translations.collect { |t| t.word }.join(', '), :type => 'html'
      entry.updated vocabulary.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")
      entry.author do |author|
        author.name vocabulary.user.name
      end
    end
  end
end