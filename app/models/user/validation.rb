
class User

  # validation concern

  def self.t_error(field, key, args = {})
    I18n.t("model.user.errors.#{field}.#{key}", args) # I18n shortcut
  end

  validates_presence_of :username, :message => t_error('username', 'required')
  validates_uniqueness_of :username, :on => :create, :case_sensitive => false, :message => t_error('username','taken')
  validates_length_of :username, :within => 3..20, :message => t_error('username', 'invalid_size')
  validates_format_of :username, :with => Authentication.login_regex, :message => t_error('username', 'invalid_format')

  validates_presence_of :email, :message => t_error('email', 'required')
  validates_uniqueness_of :email, :on => :create, :case_sensitive => false, :message => t_error('email', 'taken')
  validates_length_of :email, :within => 1..100, :message => t_error('email', 'invalid_size')
  validates_format_of :email, :with => Authentication.email_regex, :message => t_error('email', 'invalid_format')

  validate :validate_password, :validate_counters

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
        if !(5..40).include?(self.password.size)
          add_error :password, 'invalid_size'
        elsif self.password != self.password_confirmation
          add_error :password_confirmation, 'invalid_confirmation'
        end
      end
    end

    def password_required?
      false # prevents restful_authentication from validating password
    end
    
    # This validation will raise an error if uploaded or downloaded are negative,
    # it is the responsability of the controllers to ensure that no operation let
    # the model in such state.
    def validate_counters
      raise 'user counter cannot be negative' if self.uploaded < 0 || self.downloaded < 0
    end
end



