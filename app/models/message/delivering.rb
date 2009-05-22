
class Message

  # delivering concern

  def deliver(replied_id = nil)
    if valid?
      delete_replied(replied_id) if replied_id && self.sender.delete_on_reply
      save
      save_sent if self.sender.save_sent?
      self.owner.toggle! :has_new_message unless self.owner.has_new_message?
      return true
    end
    false
  end
  
  def self.deliver_system_notification(receiver, subject, body)
    begin
      m = new
      m.owner = m.receiver = receiver
      m.sender = User.system_user
      m.unread = true
      m.folder = INBOX
      m.subject = subject
      m.body = body
      m.deliver
      logger.debug ":-) system notification '#{subject}' sent to #{receiver.username}" if logger
    rescue => e
      ErrorLog.log_error e # not critical, just log the error
    end
  end
  
  private

    def save_sent
      clone = self.clone
      clone.owner = self.sender
      clone.folder = SENT
      clone.save
    end
end
