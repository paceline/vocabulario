class Transformation < ActiveRecord::Base
  
  # Attributes
  attr_writer :start_in_back, :use_open_range
  
  # Associations
  belongs_to :vocabulary
  
  # Features
  acts_as_list :scope => :vocabulary
  
  # Extracts start pattern from vocabulary
  def extract_pattern(word)
    if pattern_start && pattern_end
      if pattern_start < 0
        return word[pattern_start,pattern_end]
      else
        return word[pattern_start..pattern_end]
      end
    end
    return word
  end
  
  # Interprets 0 and -1 insert_before values
  def insert_before_as_text
    return case insert_before
      when -1 then "back"
      when 0 then "front"
      else "position #{insert_before}"
    end
  end
  
  # Sets pattern_start and pattern_end
  def set_range(start, stop, back, open)
    if back > 0
      self.pattern_start = start - vocabulary.word.size
      self.pattern_end = stop - start + 1
    else
      self.pattern_start = start
      self.pattern_end = open > 0 ? 0 : stop
    end
  end
  
  # Helper method for intepreting pattern_start and pattern_end
  def start_in_back
    if pattern_start && pattern_end
      pattern_start < 0 || pattern_end < 0
    end
    return false
  end
  
  # Helper method for intepreting pattern_start and pattern_end
  def use_open_range
    pattern_end == 0
  end
  
end
