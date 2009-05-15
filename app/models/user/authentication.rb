
class User
  include Authentication, Authentication::ByPassword # restful_authenticaton plugin
  
  # authentication concern

  attr_accessor :password_confirmation  

  REMEMBER_ME_PERIOD = 1.month

  def self.authenticate(username, password)
    u = find_by_username username
    if u && u.authenticated?(password)
      return u
    end
    nil
  end

  def logged_in?(remember_token)
    active? && self.remember_token == remember_token && self.remember_token_expires_at > Time.now
  end

  def log_in(remember_me, inactivity_threshold)
    self.last_login_at = Time.now
    reset_remember_token
    self.remember_token_expires_at = remember_me ? REMEMBER_ME_PERIOD.from_now : inactivity_threshold
    logger.debug ":-) remember token expires at: #{self.remember_token_expires_at}"
    save
  end

  def log_out
    self.remember_token_expires_at = Time.now
  end

  def register_access(inactivity_threshold)
    if self.last_request_at.blank? || self.last_request_at < 3.minutes.ago
      self.last_request_at = Time.now
      do_save = true
    end
    if self.remember_token_expires_at <= inactivity_threshold
      self.remember_token_expires_at = inactivity_threshold # slide token expiration if needed
      do_save = true
    end
    save if do_save
  end

  def reset_remember_token
    self.remember_token = self.class.make_token
  end

  # password recovery

  def change_password(password, confirmation)
    if password.blank?
      add_error :password, 'required'
      false
    else
      self.password = password
      self.password_confirmation = confirmation
      save
    end
  end

  def create_password_recovery    
    PasswordRecovery.create self, self.class.make_password_recovery_code
  end

  def self.make_password_recovery_code
    CryptUtils.md5_token
  end
end












