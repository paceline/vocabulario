class DynamicList < List
  
  # Returns vocabularies associated with list
  def vocabularies
    conditions = ["vocabularies.language_id = #{language_from.id}"]
    includes = []
    order = []
    
    unless tag_list.blank?
      conditions << "taggings.tag_id IN ('#{tags.collect { |t| t.id }.join('\',')}')"
      includes << :taggings
    end
    
    unless time_value.blank? || time_unit.blank?
      conditions << case time_unit
        when 'days' then "DATEDIFF(CURDATE(), vocabularies.created_at) <= #{time_value}"
        when 'weeks' then "DATEDIFF(CURDATE(), vocabularies.created_at) <= #{time_value*7}"
        when 'months' then "DATEDIFF(CURDATE(), vocabularies.created_at) <= #{time_value*30}"
      end
      order << 'vocabularies.created_at DESC'
    end
    
    Vocabulary.find(:all, :conditions => conditions.join(' AND '), :include => includes, :order => order.join(', '))
  end

end