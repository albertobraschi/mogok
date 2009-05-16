
class User

  # password recovery concern

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