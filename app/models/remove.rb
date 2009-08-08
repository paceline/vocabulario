class Remove < Transformation
  
  # Executes transformation on associated vocabulary
  def execute(vocabulary, previous, person)
    word = use_previous_output ? previous : vocabulary.word
    if pattern_start > 0 
      return word[0..pattern_start-1] + word[pattern_end+1..word.size]
    else
      return word[pattern_end+1..word.size]
    end
  end
  
end