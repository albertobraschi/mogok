
class SignupBlock < ActiveRecord::Base

  def still_blocked?
    self.blocked_until > Time.now
  end
end
