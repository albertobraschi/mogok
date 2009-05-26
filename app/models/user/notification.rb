
class User

  # notification concern
 
  private

    def deliver_notification(subject_key, body_key, body_args = {})
      s = I18n.t("model.user.#{subject_key}")
      b = I18n.t("model.user.#{body_key}", body_args)
      Message.deliver_system_notification self, s, b
    end

    def notify_passkey_resetting
      deliver_notification('notify_passkey_resetting.subject', 'notify_passkey_resetting.body')
    end
    
    def notify_ratio_watch
      deliver_notification('notify_ratio_watch.subject',
                           'notify_ratio_watch.body',
                           :watch_until => I18n.l(self.ratio_watch_until, :format => :date))
    end
end
