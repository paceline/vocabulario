require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  
  has_many :scores
  has_many :vocabularies
  has_many :languages

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:login => login.downcase} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  def new_random_password
    self.password = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--")[0,6]
    self.password_confirmation = self.password
    UserMailer.deliver_forgot_password(self)
  end
  
  def number_of_tests(percentile = 0)
    return scores.count({ :conditions => ['points/questions >= ?',percentile] })
  end
  
  def contributor_rank
    top_list = User.find(:all, :include => 'vocabularies', :group => 'users.id', :order => 'COUNT(vocabularies.id) DESC')
    return top_list.index(self) + 1
  end
  
  def score_rank
    top_list = User.find(:all, :include => 'scores', :group => 'users.id', :order => 'AVG(scores.points / scores.questions * 100) DESC')
    return top_list.index(self) + 1
  end
  
  def average_score
    return self.scores.average('points / questions * 100')
  end

  protected
    
    def make_activation_code
        self.deleted_at = nil
        self.activation_code = self.class.make_token
    end


end
