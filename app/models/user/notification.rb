
class User

  # notification concern

  private

    def deliver_notification(user, subject_key, body_key, body_args = {})
      s = I18n.t("model.user.#{subject_key}")
      b = I18n.t("model.user.#{body_key}", body_args)
      Message.deliver_system_notification user, s, b
    end

    def notify_passkey_resetting
      deliver_notification(self, 'notify_passkey_resetting.subject', 'notify_passkey_resetting.body')
    end
end
