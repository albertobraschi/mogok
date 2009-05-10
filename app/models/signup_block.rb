
class SignupBlock < ActiveRecord::Base

  def blocked?
    self.blocked_until > Time.now
  end
end
