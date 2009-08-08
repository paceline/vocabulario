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
  
end
