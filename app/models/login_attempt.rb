
class LoginAttempt < ActiveRecord::Base

  validates_presence_of :ip, :message => 'ip required'
  validates_uniqueness_of :ip, :message => 'duplicated ip'

  def blocked?
    !self.blocked_until.nil? && self.blocked_until > Time.now
  end

  def increment_or_block(max_attempts, block_time_hours)
    if self.attempts_count < (max_attempts - 1)
      self.attempts_count += 1
    else
      self.blocked_until = block_time_hours.hours.from_now
      self.attempts_count = 0
    end
    save
  end

  def self.delete_all_by_ip(ip)
    delete_all ['ip = ?', ip]
  end

  def self.fetch(ip)
    find_by_ip(ip) || new(:ip => ip, :attempts_count => 0)
  end

  def self.delete_all_for_expired_blocked_until
     delete_all ['blocked_until IS NOT NULL AND blocked_until < ?', Time.now]
  end
end
