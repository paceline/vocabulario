class DynamicList < List
  
  # Returns vocabularies associated with list
  def vocabularies
    conditions = ["vocabularies.language_id = #{language_from.id}"]
    order = ['vocabularies.word']
    
    unless time_value.blank? || time_unit.blank?
      conditions << case time_unit
        when 'days' then "DATEDIFF(CURDATE(), vocabularies.created_at) <= #{time_value}"
        when 'weeks' then "DATEDIFF(CURDATE(), vocabularies.created_at) <= #{time_value*7}"
        when 'months' then "DATEDIFF(CURDATE(), vocabularies.created_at) <= #{time_value*30}"
      end
      order << 'vocabularies.updated_at DESC'
    end
    
    if tag_list.blank?
      Vocabulary.find(:all, :conditions => conditions.join(' AND '), :order => order.reverse.join(', '))
    else
      Vocabulary.find_tagged_with(tags, :match_all => all_or_any, :conditions => conditions.join(' AND '), :order => order.reverse.join(', '))
    end
  end

end