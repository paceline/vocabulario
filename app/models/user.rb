class User < ActiveRecord::Base
  
  # Features
  include Clearance::User
  attr_accessible :email, :name
  has_permalink :name
  
  # Associations
  has_many :comments
  has_many :lists, :order => 'name'
  has_many :scores
  has_many :vocabularies
  has_many :languages
  has_many :client_applications
  has_many :tokens, :class_name => "OauthToken", :order => "authorized_at desc", :include => [:client_application]
  
  # Validations
  validates_presence_of :email, :name
  validates_length_of :name, :within => 1..100
  validates_uniqueness_of :name
  
  # Statistics - Average score
  def average_score
    return self.scores.average('points / questions * 100')
  end
  
  # Statistics - Contributor rank
  def contributor_rank
    top_list = User.find(:all, :include => 'vocabularies', :group => 'users.id', :order => 'COUNT(vocabularies.id) DESC')
    return top_list.index(self) + 1
  end
  
  # Statistics - Numer of tests taken
  def number_of_tests(percentile = 0)
    return scores.count({ :conditions => ['points/questions >= ?',percentile] })
  end
  
  # Returns profile url
  def profile_url
    "http://#{HOST}/users/#{permalink}"
  end
  
  # Statistics - Score rank
  def score_rank
    top_list = User.find(:all, :include => 'scores', :group => 'users.id', :order => 'AVG(scores.points / scores.questions * 100) DESC')
    return top_list.index(self) + 1
  end
  
  # Export as hash
  def to_hash(admin = false)
    admin ? { :id => id, :name => name, :email => email, :created_at => created_at, :url => profile_url } : { :id => id, :name => name, :created_at => created_at, :url => "http://#{HOST}/users/#{permalink}" }
  end
  
end
