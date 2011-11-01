module VocabulariesHelper
  include InPlaceEditorHelper
 
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
  
  def random_hint
    case rand(4)
      when 0 then "german:bauer"
      when 1 then "translate:bauer"
      when 2 then "noun:bauer"
      when 3 then "Lezione 5:bauer"
    end
  end
end