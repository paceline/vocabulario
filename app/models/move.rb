class Move < Transformation
  
  # Executes transformation on associated vocabulary
  def execute(vocabulary, word, person)
    end_pattern = pattern_end < pattern_start ? word.size-1 : pattern_end
    part = word[pattern_start..end_pattern]
    pattern_start.upto(end_pattern) { |i| word[i] = "^" }
    
    word = case insert_before
      when -1 then word + (include_white_space ? " #{part}" : part)
      when 0 then (include_white_space ? "#{part} " : part) + word
      else word[0..insert_before-1] + part + word[insert_before..word.size]
    end
    
    return word.gsub("^","")
  end
  
end