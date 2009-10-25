class DynamicList < List
  
  # Returns vocabularies associated with list
  def vocabularies
    conditions = ["vocabularies.language_id = #{language_from.id}"]
    joins = []
    order = []
    
    unless tag_list.blank?
      conditions << "taggings.tag_id IN ('#{tags.collect { |t| t.id }.join('\',\'')}')"
      joins << "LEFT JOIN taggings ON taggings.taggable_id = vocabularies.id"
    end
    
    unless time_value.blank? || time_unit.blank?
      conditions << case time_unit
        when 'days' then "DATEDIFF(CURDATE(), vocabularies.created_at) <= #{time_value}"
        when 'weeks' then "DATEDIFF(CURDATE(), vocabularies.created_at) <= #{time_value*7}"
        when 'months' then "DATEDIFF(CURDATE(), vocabularies.created_at) <= #{time_value*30}"
      end
      order << 'vocabularies.updated_at DESC'
    end
    
    Vocabulary.find_by_sql("SELECT * FROM vocabularies #{joins.join(' AND ')} WHERE #{conditions.join(' AND ')} #{'ORDER BY ' + order.join(', ') unless order.blank?}")
  end

end