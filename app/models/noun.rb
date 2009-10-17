class Noun < Vocabulary
  
  # Imports csv string
  def import(user, tags)
    tmp = word.split(',')
    self.word = tmp[0].strip
    self.gender = tmp[1].strip if tmp.size > 1
    super
  end

end