class Noun < Vocabulary
  
  # Features
  has_permalink :name, :update => true
  
  # Supported articles
  ARTICLES = ["la ","le ","el ","il ","l'","lo ","i ","der ","die ","das ","the ","les ","los ","las "]
  
  # Automatically interpret word
  def word=(value)
    if (tmp = value.split(',')).size > 1
      write_attribute(:gender, tmp[tmp.size-1].strip)
      write_attribute(:word, tmp[0..tmp.size-2].join(',').strip)
    elsif (article = find_matching_articles(value))
      write_attribute(:gender, article.strip)
      write_attribute(:word, value[article.size..value.size-1].strip)
    else
      write_attribute(:word, value)
    end
  end
  
  # Always returns article with word
  def word
    gender? ? (gender.include?('\'') ? "#{gender}#{read_attribute(:word)}" : "#{gender} #{read_attribute(:word)}") : read_attribute(:word)
  end
  
  private
    def find_matching_articles(value)
      ARTICLES.each do |article|
        return article if article.casecmp(value[0..article.size-1]) == 0
      end
      return false
    end

end