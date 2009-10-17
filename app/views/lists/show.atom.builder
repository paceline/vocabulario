atom_feed do |feed|
  feed.title @list.name
  feed.subtitle "A Vocabulario list by #{@list.user.name}"
  feed.updated @list.class == StaticList ? @list.updated_at : @vocabularies.first.created_at
 
  for vocabulary in @vocabularies
    next if vocabulary.updated_at.blank?
    feed.entry(vocabulary, :url => vocabulary_path(vocabulary.permalink)) do |entry|
      entry.title vocabulary.word
      entry.content vocabulary.translations(@list.language_to).collect { |t| t.word }.join(', '), :type => 'html'
      entry.updated vocabulary.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")
      entry.author do |author|
        author.name vocabulary.user.name
      end
    end
  end
end