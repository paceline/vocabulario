class Score < ActiveRecord::Base
  belongs_to :language, :class_name => 'Vocabulary'
  belongs_to :user
  
  # Return % of correct answers
  def ratio
    return questions > 0 ? (points.to_f/questions.to_f)*100 : 0
  end
  
  # Return top scores by percentage
  def self.top_percentage(limit = 0)
    if limit == 0
      return find(:all, :order => "points / questions * 100 DESC, questions DESC")
    end
    return find(:all, :order => "points / questions * 100 DESC, questions DESC", :limit => limit)
  end
  
end
