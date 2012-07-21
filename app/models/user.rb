class User < ActiveRecord::Base
  
  # Features
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  include Gravtastic
  gravtastic :size => 75
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :default_to, :default_from, :permalink, :admin, :id
  permalink :name
  
  # Associations
  has_many :comments
  has_many :lists, :order => 'name'
  has_many :scores
  has_many :vocabularies
  has_many :languages
  has_many :client_applications
  has_many :tokens, :class_name => "OauthToken", :order => "authorized_at desc", :include => [:client_application]
  has_many :wiki_pages, :foreign_key => 'creator_id'
  
  # Validations
  validates :email, :presence => true
  validates :name, :presence => true, :uniqueness => true, :length => { :minimum => 1, :maximum => 100 }
  
  # Defaults
  default_scope order('`users`.`name`')
  
  # Statistics - Average score
  def average_score
    return self.scores.average('points / questions * 100')
  end
  
  # Statistics - Contributor rank
  def contributor_rank
    top_list = User.find(:all, :include => 'vocabularies', :group => 'users.id', :order => 'COUNT(vocabularies.id) DESC')
    return top_list.index(self) + 1
  end
  
  # Check whether defaults are set
  def defaults?
    self.default_to && self.default_from
  end
  
  # Statistics - Numer of tests taken
  def number_of_tests(percentile = 0)
    return scores.count({ :conditions => ['points/questions >= ?',percentile] })
  end
  
  # Returns profile url
  def profile_url
    "http://#{::Rails.configuration.action_mailer.default_url_options[:host]}/users/#{permalink}"
  end
  
  # Statistics - Score rank
  def score_rank
    top_list = User.find(:all, :include => 'scores', :group => 'users.id', :order => 'AVG(scores.points / scores.questions * 100) DESC')
    return top_list.index(self) + 1
  end
  
  # Export as hash
  def to_hash(admin = false)
    admin ? { :id => id, :name => name, :email => email, :created_at => created_at, :url => profile_url } : { :id => id, :name => name, :created_at => created_at, :url => "http://#{::Rails.configuration.action_mailer.default_url_options[:host]}/users/#{permalink}" }
  end
  
end
