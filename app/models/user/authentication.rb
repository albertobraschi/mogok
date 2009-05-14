
class User

  # authentication concern

  attr_reader :password
  attr_accessor :password_confirmation  

  def self.authenticate(username, password)
    u = self.find_by_username username
    if u && u.crypted_password == CryptUtils.encrypt_password(password, u.password_salt)
      return u
    end
    nil
  end

  def self.make_password_recovery_code
    CryptUtils.md5_token
  end

  def register_access(inactivity_threshold)
    if self.last_request_at.blank? || self.last_request_at < 3.minutes.ago
      self.last_request_at = Time.now
      do_save = true
    end

    if self.token_expires_at <= inactivity_threshold
      self.token_expires_at = inactivity_threshold # slide token expiration
      do_save = true
    end
    
    save if do_save
  end

  def log_in(keep_logged_in, inactivity_threshold)
    self.last_login_at = Time.now
    reset_token
    self.token_expires_at = keep_logged_in ? 30.days.from_now : inactivity_threshold
    save
  end

  def password=(password)    
    unless password.blank?
      self.password_salt = CryptUtils.md5_token object_id
      self.crypted_password = CryptUtils.encrypt_password password, self.password_salt
    end
    @password = password
  end

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

  def reset_token
    self.token = CryptUtils.md5_token self.id, 20
  end

  def create_password_recovery    
    PasswordRecovery.create self, self.class.make_password_recovery_code
  end
end












