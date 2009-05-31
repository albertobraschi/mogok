
class SignupBlock < ActiveRecord::Base

  def blocked?
    self.blocked_until > Time.now
  end

  def self.create(ip, blocked_until)
    super :ip => ip, :blocked_until => blocked_until
  end

  def self.delete_all_for_expired_blocked_until
     delete_all ['blocked_until IS NOT NULL AND blocked_until < ?', Time.now]
  end
end
