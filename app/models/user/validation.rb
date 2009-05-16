
class User

  # validation concern

  def self.t_error(field, key, args = {})
    I18n.t("model.user.errors.#{field}.#{key}", args)
  end

  validates_presence_of :username, :message => t_error('username', 'required')
  validates_uniqueness_of :username, :on => :create, :case_sensitive => false, :message => t_error('username','taken')
  validates_length_of :username, :within => 3..20, :message => t_error('username', 'invalid_length')
  validates_format_of :username, :with => Authentication.login_regex, :message => t_error('username', 'invalid_format')

  validates_presence_of :email, :message => t_error('email', 'required')
  validates_uniqueness_of :email, :on => :create, :case_sensitive => false, :message => t_error('email', 'taken')
  validates_length_of :email, :within => 6..100, :message => t_error('email', 'invalid_length')
  validates_format_of :email, :with => Authentication.email_regex, :message => t_error('email', 'invalid_format')

  validate :validate_password

  def add_error(field, key, args = {})
    errors.add field, self.class.t_error(field.to_s, key, args)
  end

  def self.valid_email?(email)
    email =~ Authentication.email_regex
  end

  private

    def validate_password
      if self.crypted_password.blank? && self.password.blank?
        add_error :password, 'required'
      elsif self.password
        if self.password.size < 5
          add_error :password, 'too_short'
        elsif self.password != self.password_confirmation
          add_error :password_confirmation, 'invalid_confirmation'
        end
      end
    end

    def password_required?
      false # prevents restful_authentication from validating password
    end
end



