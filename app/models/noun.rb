class Noun < Vocabulary
  
  # Imports csv string
  def import(user, tags, new_tags)
    if self.word.include?(',')
      tmp = self.word.split(',')
      self.word = tmp[0].strip
      self.gender = tmp[1].strip
    else
      tmp = self.word.split(' ')
      if tmp.size > 1
        self.gender = tmp[0].strip
        self.word = self.word.sub(self.gender,'').strip
      end
    end
    super
  end
  
  # Always returns article with word
  def word
    gender ? "#{gender} #{read_attribute(:word)}" : read_attribute(:word)
  end

end