class ReplaceEnding < Transformation
  
  # Executes transformation on associated vocabulary
  def execute(vocabulary, word, text)
    if pattern_start < 0
      return word[0..word.size-1+pattern_start] + text + word[word.size-1+pattern_start+pattern_end..word.size-1]
    else
      first = pattern_start == 0 ? "" : word[0..pattern_start-1]
      last = pattern_end+1 == word.size ? "" : word[pattern_end+1..word.size-1]
      return first + text + last
    end
  end
  
end