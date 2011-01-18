class OauthToken < ActiveRecord::Base
  belongs_to :client_application
  belongs_to :user
  validates :client_application, :secret, :presence => true
  validates :token, :presence => true, :uniqueness => true
  before_validation :generate_keys, :on => :create
  
  def invalidated?
    invalidated_at != nil
  end
  
  def invalidate!
    update_attribute(:invalidated_at, Time.now)
  end
  
  def authorized?
    authorized_at != nil && !invalidated?
  end
    
  def to_query
    "oauth_token=#{token}&oauth_token_secret=#{secret}"
  end
    
  protected
  
  def generate_keys
    oauth_token = client_application.oauth_server.generate_credentials
    self.token = oauth_token[0][0,20]
    self.secret = oauth_token[1][0,40]
  end
end
