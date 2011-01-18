module UsersHelper
  
  def navigation_for(scores, tag = "", type = "", current_page = 1)
    start = 1
    links = []
    1.upto(scores.total_pages) do |i|
      ending = i * scores.per_page
      active_or_inactive = current_page == i ? 'active' : 'inactive'
      links << link_to("#{start}-#{ending}", statistics_user_path(@user.permalink, :tag => tag, :type => type, :page => i), :remote => true, :method => :post, :class => "lengthy #{active_or_inactive}")
      start = ending + 1
    end
    return links.join('&nbsp;&nbsp;&nbsp;&nbsp;')
  end
  
end
