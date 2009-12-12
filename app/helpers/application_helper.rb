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
    return "highlight()"
  end
  
  def interpret_flash_key(key)
    keys = { :failure => 'Nope', :success => 'Great', :notice => 'Done' }
    return keys[key]
  end
  
  def update_notice()
    page.replace_html :notice, render(:partial => 'layouts/flashes')
    page.show :notice
    page.visual_effect :highlight, 'notice'
  end
  
end
