class Score < ActiveRecord::Base
  
  # Associations
  belongs_to :language_from, :foreign_key => 'language_from_id', :class_name => 'Language'
  belongs_to :language_to, :foreign_key => 'language_to_id', :class_name => 'Language'
  belongs_to :user
  
  # Return % of correct answers
  def ratio
    return questions > 0 ? points.to_f/questions.to_f*100 : 0
  end
  
  # Return top scores by percentage
  def self.top_percentage(limit = 0)
    if limit == 0
      return find(:all, :order => "points/questions*100 DESC, questions DESC")
    end
    return find(:all, :order => "points/questions*100 DESC, questions DESC", :limit => limit)
  end
  
  # Get personal pronouns based on target language
  def personal_pronouns
    pronoun = Person.find(:first, :conditions => ["language_id = ? AND pronoun = 'personal'", self.language_to_id])
    return pronoun ? pronoun.set_as_list : ['I','You','He/She/It','We','You','They']
  end
  
end
