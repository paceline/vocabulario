# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  
  def on_load()
    if flash.empty?
      if @current_action == 'statistics'
        return "getGraphData('#{current_user.permalink}')"
      end
      return ""
    end
    return "highlightNotice()"
  end
  
  def interpret_flash_key(key)
    keys = { :failure => 'Nope', :success => 'Great', :notice => 'Done' }
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
  
  def update_notice()
    page.replace_html :notice, render(:partial => 'layouts/flashes')
    page.show :notice
    page.visual_effect :highlight, 'notice'
  end
  
  def set_link_class(action,active=0)
    action == active ? "tab_link active" : "tab_link"
  end

  def detect_elements
    @vocabulary && !@vocabulary.new_record? ? "['add','copy','delete']" : "['add']"
  end
  
end
