
class LoginAttempt < ActiveRecord::Base

  def blocked?
    self.blocked_until && self.blocked_until > Time.now
  end
end
