
class SignupBlock < ActiveRecord::Base

  def blocked?
    self.blocked_until > Time.now
  end

  def self.create(ip, blocked_until)
    super :ip => ip, :blocked_until => blocked_until
  end
end
