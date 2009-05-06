
class LoginAttempt < ActiveRecord::Base

  def blocked?
    self.blocked_until && self.blocked_until > Time.now
  end

  def self.delete_all_by_ip(ip)
    delete_all ['ip = ?', ip]
  end
end
