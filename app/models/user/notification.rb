
class User

  # notification concern

  def deliver_notification(subject, body)
    Message.deliver_system_notification self, subject, body
  end

  private

    def translate_and_deliver(subject_key, body_key, body_args = {})
      s = I18n.t("model.user.#{subject_key}")
      b = I18n.t("model.user.#{body_key}", body_args)
      deliver_notification s, b
    end

    def notify_passkey_resetting
      translate_and_deliver('notify_passkey_resetting.subject', 'notify_passkey_resetting.body')
    end
    
    def notify_ratio_watch
      translate_and_deliver('notify_ratio_watch.subject',
                            'notify_ratio_watch.body', :watch_until => I18n.l(self.ratio_watch_until, :format => :date))
    end
end
