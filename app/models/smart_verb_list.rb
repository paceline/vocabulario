class SmartVerbList < List
  
  # Features
  has_permalink :name, :update => true
  
  # Returns vocabularies associated with list
  def vocabularies(custom_attribute = "", custom_order = "")
    conditions = ["vocabularies.language_id = #{language_from.id}","vocabularies.type = 'Verb'"]
    order = custom_attribute.blank? ? ['vocabularies.word'] : ["#{custom_attribute} #{custom_order}"]
    
    unless time_value.blank? || time_unit.blank?
      conditions << case time_unit
        when 'days' then "DATEDIFF(CURDATE(), vocabularies.created_at) <= #{time_value}"
        when 'weeks' then "DATEDIFF(CURDATE(), vocabularies.created_at) <= #{time_value*7}"
        when 'months' then "DATEDIFF(CURDATE(), vocabularies.created_at) <= #{time_value*30}"
      end
      order << 'vocabularies.updated_at DESC' if custom_attribute.blank?
    end
    
    if tag_list.blank?
      Vocabulary.find(:all, :conditions => conditions.join(' AND '), :order => order.reverse.join(', '))
    else
      Vocabulary.find_tagged_with(tags, :match_all => all_or_any, :conditions => conditions.join(' AND '), :order => order.reverse.join(', '))
    end
  end
  
end