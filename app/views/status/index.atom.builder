atom_feed do |feed|
  feed.title "Recent activity"
  feed.subtitle "Recent activity on Vocabulario"
  feed.updated @timeline.first[:created_at]
 
  for item in @timeline
    next if item[:created_at].blank?
    feed.entry(item, :url => item.key?(:url) ? item[:url] : (item[:user].blank? ? sign_up_url : item[:user][:url])) do |entry|
      entry.title "#{item[:user].blank? ? 'Guest' : item[:user][:name]} #{item[:text]}"
      entry.content "#{item[:user].blank? ? 'Guest' : item[:user][:name]} #{item[:text]}", :type => 'html'
      entry.updated item[:created_at].strftime("%Y-%m-%dT%H:%M:%SZ")
      entry.author do |author|
        author.name item[:user].blank? ? 'Guest' : item[:user][:name]
      end
    end
  end
end