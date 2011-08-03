atom_feed do |feed|
  feed.title @list.name + (@list.verb? ? " (in #{ConjugationTime.find(@tense_id).name})" : "")
  feed.subtitle "A Vocabulario list by #{@list.user.name}"
  feed.updated @list.static? ? @list.updated_at : @list.vocabularies.first.created_at
 
  for vocabulary in @list.vocabularies
    next if vocabulary.updated_at.blank?
    feed.entry(vocabulary, :url => vocabulary_path(vocabulary.permalink)) do |entry|
      entry.title vocabulary.word
      entry.content(
        if @list.verb?
          begin
            vocabulary.conjugate_all(@tense_id).collect { |t| t }.join(', ')
          rescue
            "No conjugation patterns have been added yet"
          end
        else
          vocabulary.translations.all(@list.language_to.id).collect { |t| t.word }.join(', ')
        end
      )
      entry.updated vocabulary.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")
      entry.author do |author|
        author.name vocabulary.user.name
      end
    end
  end
end