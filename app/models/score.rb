class Score < ActiveRecord::Base
  
  # Features
  acts_as_taggable
  
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
  
  # Post-initialize operations
  def setup(test)
    self.language_from_id = test.class == VocabularyTest ? test.from.id : ConjugationTime.find(test.tense).language.id
    self.language_to_id = test.class == VocabularyTest ? test.to.id : language_from_id
    self.tag_list = test.tags
  end
  
  # takes a hash of finder conditions and returns a page number 
  # returns 1 if nothing was found, as not to break pagination by passing page=0 
  def self.last_page_number(conditions=nil, includes=nil) 
    total = count :all, :conditions => conditions, :include => includes
    [((total - 1) / 25) + 1, 1].max 
  end
  
  # Return updates for timline
  def updates_for_timeline
    Status[
      :id => id,
      :text => "got #{ratio}% right on a #{questions} question #{language_from.word} to #{language_to.word} test",
      :created_at => created_at,
      :user => user.to_hash
    ]
  end
  
end
