
class Torrent

  # notification concern

  private

    def deliver_notification(subject_key, body_key, body_args = {})
      s = I18n.t("model.torrent.#{subject_key}")
      b = I18n.t("model.torrent.#{body_key}", body_args)
      Message.deliver_system_notification self.user, s, b
    end

    def notify_inactivation(inactivator, reason)
      deliver_notification('notify_inactivation.subject',
                           'notify_inactivation.body',
                           :name => self.name, :by => inactivator.username, :reason => reason)
    end

    def notify_activation(activator)
      deliver_notification('notify_activation.subject',
                           'notify_activation.body',
                           :name => self.name, :by => activator.username)
    end

    def notify_destruction(destroyer, reason)
      deliver_notification('notify_destruction.subject',
                           'notify_destruction.body',
                           :name => self.name, :by => destroyer.username, :reason => reason)
    end
end