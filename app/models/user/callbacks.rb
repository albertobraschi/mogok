
class User

  # callbacks concern

  before_create :init_new_record
  before_save :trim_info
  before_destroy :ensure_not_default

  private

    def init_new_record
      self.role = Role.find_by_name(Role::USER) unless self.role
      self.reset_passkey
      self.style = Style.find(:first) unless self.style
    end

    def trim_info
      self.info = self.info[0, 4000] if self.info
    end

    def ensure_not_default
      raise ArgumentError if self.id == 1
    end
end