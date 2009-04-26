
module MessageNotification

  protected

  def notify_torrent_inactivated(t, u, reason)
    m = new_system_message t.user
    m.subject = I18n.t('lib.message_notification.notify_torrent_inactivated.subject')
    m.body = I18n.t('lib.message_notification.notify_torrent_inactivated.body', :name => t.name, :by => u.username, :reason => reason)
    send_message m
  end

  def notify_torrent_deleted(t, u, reason)
    m = new_system_message t.user
    m.subject = I18n.t('lib.message_notification.notify_torrent_deleted.subject')
    m.body = I18n.t('lib.message_notification.notify_torrent_deleted.body', :name => t.name, :by => u.username, :reason => reason)
    send_message m
  end

  def notify_passkey_reset(u)
    m = new_system_message u
    m.subject = I18n.t('lib.message_notification.notify_passkey_reset.subject')
    m.body = I18n.t('lib.message_notification.notify_passkey_reset.body')
    send_message m
  end

  private

  def new_system_message(receiver)
    m = Message.new
    m.owner = m.receiver = receiver
    m.sender = User.system_user
    m.created_at = Time.now
    m.unread = true
    m.folder = Message::INBOX
    m
  end

  def send_message(m)
    begin
      m.save!
      m.owner.toggle! :has_new_message unless m.owner.has_new_message?
      logger.debug ":-) notification message '#{m.subject}' sent to #{m.receiver.username}" if logger
    rescue => e
      log_error e # not critical, so just log the error
    end
  end
end