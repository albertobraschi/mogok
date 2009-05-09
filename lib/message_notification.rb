
module MessageNotification

  protected

  def deliver_message_notification(receiver, subject, body)
    begin
      Message.deliver_system_message(receiver) do |m|
        m.subject = subject
        m.body = body
      end      
      logger.debug ":-) notification message '#{subject}' sent to #{receiver.username}" if logger
    rescue => e
      log_error e # not critical, just log the error
    end
  end
end