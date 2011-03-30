class Noun < Vocabulary
  
  # Automatically interpret word
  def word=(value)
    if (tmp = value.split(',')).size > 1
      write_attribute(:word, tmp[0].strip)
      write_attribute(:gender, tmp[1].strip)
    else
      if (tmp = value.split('\'')).size > 1
        write_attribute(:gender, "#{tmp[0].strip}'")
        write_attribute(:word, tmp[1].strip)
      else
        if (tmp = value.split(' ')).size > 1
          write_attribute(:gender, tmp[0].strip)
          write_attribute(:word,value.sub(self.gender,'').strip)
        else
          write_attribute(:word, tmp[0])
        end
      end
    end
  end
  
  # Always returns article with word
  def word
    gender? ? (gender.include?('\'') ? "#{gender}#{read_attribute(:word)}" : "#{gender} #{read_attribute(:word)}") : read_attribute(:word)
  end

end