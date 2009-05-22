
class Wish

  # notification concern

  private

    def deliver_notification(user, subject_key, body_key, body_args = {})
      s = I18n.t("model.wish.#{subject_key}")
      b = I18n.t("model.wish.#{body_key}", body_args)
      Message.deliver_system_notification user, s, b
    end

    def notify_approval
      # notify user who filled the wish
      deliver_notification(self.filler,
                           'notify_approval.filler_subject',
                           self.total_bount > 0 ? 'notify_approval.filler_body_with_amount' : 'notify_approval.filler_body',
                           :name => self.name, :amount => self.total_bounty)

      # notify user who created the wish
      deliver_notification(self.user,
                           'notify_approval.wisher_subject',
                           'notify_approval.wisher_body',
                           :name => self.name, :by => self.filler.username)

      # notify users who have bounties for the wish
      unless self.wish_bounties.blank?
        self.wish_bounties.each do |wb|
          deliver_notification(wb.user,
                               'notify_approval.bounter_subject',
                               'notify_approval.bounter_body',
                               :name => self.name, :by => self.filler.username)
        end
      end
    end

    def notify_rejection(rejecter, reason)
      deliver_notification(self.filler,
                           'notify_rejection.subject',
                           'notify_rejection.body',
                           :name => self.name, :by => rejecter.username, :reason => reason)
    end

    def notify_destruction(destroyer, reason)
      deliver_notification(self.user,
                           'notify_destruction.subject',
                           'notify_destruction.body',
                            :name => self.name, :by => destroyer.username, :reason => reason)
    end
end