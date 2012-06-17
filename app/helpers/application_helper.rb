module ApplicationHelper
  include TagsHelper
  
  def interpret_flash_key(key)
    keys = { :alert => 'Sorry', :notice => 'Great' }
    return keys[key]
  end
  
  def map_action(action)
    case action
      when 'index' then 'index_tab_0'
      when 'by_language' then 'index_tab_1'
      when 'by_tag' then 'index_tab_2'
      when 'by_type' then 'index_tab_3'
    end
  end
  
  def update_notice
    page.replace_html :notice, render(:partial => 'layouts/flashes')
    page.show :notice
  end
  
  def set_link_class(action,active=0,first=0)
    action == active ? "tab_link#{" first" if first == 0} active" : "tab_link#{" first" if first == 0}"
  end

  def detect_elements
    @vocabulary && !@vocabulary.new_record? ? "['add','copy','delete']" : "['add']"
  end
  
  def select_with_defaults(object, method, collection, selected = {}, default = nil)
    if current_user && current_user.send("default_#{default ? default : method}")
      selected = { :selected => current_user.send("default_#{default ? default : method}") }
    end
    select(object, method, collection, selected)
  end
end
