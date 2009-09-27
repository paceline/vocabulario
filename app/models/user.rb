class User < ActiveRecord::Base
  
  # Features
  include Clearance::User
  attr_accessible :name
  has_permalink :name
  
  # Associations
  has_many :lists
  has_many :scores
  has_many :vocabularies
  has_many :languages
  
  # Validations
  validates_presence_of :name
  validates_length_of :name, :within => 1..100
  validates_uniqueness_of :name
  
  # Statistics - Numer of tests taken
  def number_of_tests(percentile = 0)
    return scores.count({ :conditions => ['points/questions >= ?',percentile] })
  end
  
  # Statistics - Contributor rank
  def contributor_rank
    top_list = User.find(:all, :include => 'vocabularies', :group => 'users.id', :order => 'COUNT(vocabularies.id) DESC')
    return top_list.index(self) + 1
  end
  
  # Statistics - Score rank
  def score_rank
    top_list = User.find(:all, :include => 'scores', :group => 'users.id', :order => 'AVG(scores.points / scores.questions * 100) DESC')
    return top_list.index(self) + 1
  end
  
  # Statistics - Average score
  def average_score
    return self.scores.average('points / questions * 100')
  end
  
end
