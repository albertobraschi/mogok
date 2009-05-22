
class Message

  # callbacks concern

  before_create :set_subject, :trim_body

  private

    def set_subject
      self.subject = self.subject.blank? ? I18n.t('model.message.before_create.no_subject') : self.subject[0, 50]
    end

    def trim_body
      self.body = self.body[0, 2000] if self.body
    end
end
