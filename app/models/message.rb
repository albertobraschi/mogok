
class Message < ActiveRecord::Base
  strip_attributes! # strip_attributes plugin

  INBOX, OLDS, SENT, TRASH = 'inbox', 'olds', 'sent', 'trash'

  concerns :callbacks, :delivering, :ownership, :validation

  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  belongs_to :receiver, :class_name => 'User', :foreign_key => 'receiver_id'

  attr_accessor :replying_to # holds username of user being replied

  def set_as_read
    toggle! :unread if unread?
  end

  def move_to_folder(folder, mover)
    ensure_ownership mover
    update_attribute :folder, folder
  end

  def self.make_new(params, sender, args)
    m = new params
    unless args[:to].blank?
      m.owner = m.receiver = User.find_by_username(args[:to])
      m.sender = sender
    end
    if !args[:message_id].blank? # if replying or forwarding
      old_message = find args[:message_id]
      old_message.ensure_ownership sender
      prepare_for_reply m, old_message if args[:reply]
      prepare_for_forward m, old_message if args[:forward]
    end
    m
  end

  private

    def delete_replied(replied_id)
      unless replied_id.blank?
        m = self.class.find replied_id
        m.ensure_ownership self.sender
        m.update_attribute :folder, TRASH
      end
    end

    def self.prepare_for_reply(m, old_message)
      prefix = I18n.t('model.message.prepare_to_reply.prefix')
      wrote = I18n.t('model.message.prepare_to_reply.wrote')
      m.subject = "#{prefix unless old_message.subject.starts_with?(prefix)} #{old_message.subject}"
      m.body = "\n\n\n----
                \n#{old_message.sender.username} #{wrote}
                \n\n#{old_message.body}"
      m.replying_to = old_message.sender.username
    end

    def self.prepare_for_forward(m, old_message)
      prefix = I18n.t('model.message.prepare_to_forward.prefix')
      wrote = I18n.t('model.message.prepare_to_forward.wrote')
      m.subject = "#{ prefix unless old_message.subject.starts_with?(prefix)} #{old_message.subject}"
      m.body = "\n\n\n----
               \n#{old_message.sender.username} #{wrote}:
               \n\n#{old_message.body}"
    end
end
