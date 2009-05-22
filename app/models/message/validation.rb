
class Message

  # validation concern

  def self.t_error(field, key, args = {})
    I18n.t("model.message.errors.#{field}.#{key}", args)
  end

  FOLDERS = [INBOX, OLDS, SENT, TRASH]

  validates_presence_of :receiver_id, :message => t_error('receiver_id', 'invalid')
  validates_inclusion_of :folder, :in => FOLDERS, :message => 'invalid folder'

  validate :validate_receiver

  def self.valid_folder?(value)
    FOLDERS.include? value
  end

  def add_error(field, key, args = {})
    errors.add field, self.class.t_error(field.to_s, key, args)
  end

  private

    def validate_receiver
      if self.receiver
        if !self.receiver.active?
          add_error :receiver_id, 'inactive'
        elsif self.receiver.system_user?
          add_error :receiver_id, 'system'
        end
      end
    end
end
