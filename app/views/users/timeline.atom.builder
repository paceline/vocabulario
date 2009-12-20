atom_feed do |feed|
  feed.title "#{@timeline.first[:user][:name]}'s recent activity"
  feed.subtitle "#{@timeline.first[:user][:name]}'s recent activity on Vocabulario"
  feed.updated @timeline.first[:created_at]
 
  for item in @timeline
    next if item[:created_at].blank?
    feed.entry(item, :url => item.key?(:url) ? item[:url] : item[:user][:url]) do |entry|
      entry.title item[:text]
      entry.content item[:text], :type => 'html'
      entry.updated item[:created_at].strftime("%Y-%m-%dT%H:%M:%SZ")
      entry.author do |author|
        author.name item[:user][:name]
      end
    end
  end
end