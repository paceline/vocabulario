class Insert < Transformation
  
  # Executes transformation on associated vocabulary
  def execute(vocabulary, previous, newpart = nil)
    word = use_previous_output ? previous : vocabulary.word
    return case insert_before
      when -1 then word + (include_white_space ? " #{newpart}" : newpart)
      when 0 then (include_white_space ? "#{newpart} " : newpart) + word
      else word[0..insert_before-1] + newpart + word[insert_before..word.size]
    end
  end
  
end