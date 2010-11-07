module VocabulariesHelper
 
  def languages_for_translation(translation)
    return Language.list("id != #{translation.language_id}").collect {|p| [ p.word, p.id ] }
  end
  
  def max_array_length(multi_dimensional_array)
    max_length = 0
    multi_dimensional_array.each do |array|
      max_length = array.size > max_length ? array.size : max_length
    end
    return max_length
  end
  
  def build_pagination_url(parameters)
    url = "/#{parameters[:controller]}"
    url += "/#{parameters[:action]}" unless parameters[:action] == "index"
    url += "/#{parameters[:id]}" if parameters.key?(:id)
    return url + '.js'
  end
  
end