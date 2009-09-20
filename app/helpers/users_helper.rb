module UsersHelper
  
  def navigation_for(scores, tag = "", type = "", current_page = 1)
    start = 1
    links = []
    1.upto(scores.total_pages) do |i|
      ending = i * scores.per_page
      active_or_inactive = current_page == i ? 'active' : 'inactive'
      links << link_to_remote("#{start}-#{ending}", { :url => statistics_user_path(@user.permalink, :tag => tag, :type => type, :page => i), :method => :post, :before => "$('loading').show(); getGraphData('#{@user.permalink}','#{tag}','#{type}',#{i})" }, { :class => active_or_inactive })
      start = ending + 1
    end
    return links.join('&nbsp;&nbsp;&nbsp;&nbsp;')
  end
  
end
