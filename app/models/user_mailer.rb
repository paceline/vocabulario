class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://tuvocabulario.com/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://tuvocabulario.com"
  end
  
  def forgot_password(user)
    setup_email(user)
    @subject    += 'Your password has been reset!'
    @body[:url]  = "http://tuvocabulario.com/login"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "Soulless machine <hello@tuvocabulario.com>"
      @subject     = "[VOCABULARIO] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
