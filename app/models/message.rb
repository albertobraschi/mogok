
class Message < ActiveRecord::Base
  strip_attributes! # strip_attributes

  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  belongs_to :receiver, :class_name => 'User', :foreign_key => 'receiver_id'

  class NotOwnerError < StandardError
  end

  INBOX, OLDS, SENT, TRASH = 'inbox', 'olds', 'sent', 'trash'
  FOLDERS = [INBOX, OLDS, SENT, TRASH]

  attr_accessor :replying_to # holds username of user being replied

  def self.t_error(field, key, args = {})
    I18n.t("model.message.errors.#{field}.#{key}", args)
  end

  validates_presence_of :receiver_id, :message => t_error('receiver_id', 'invalid')
  validates_inclusion_of :folder, :in => FOLDERS, :message => 'invalid folder'

  def validate
    if self.receiver
      if !self.receiver.active?
        add_error :receiver_id, 'inactive'
      elsif self.receiver.system_user?
        add_error :receiver_id, 'system'
      end
    end
  end

  def add_error(field, key, args = {})
    errors.add field, self.class.t_error(field.to_s, key, args)
  end

  def before_save
    self.subject = self.subject[0, 50]
    self.body = self.body[0, 2000] if self.body
  end

  def self.valid_folder?(value)
    FOLDERS.include? value
  end

  def self.make_new(params, sender, args)
    m = new params
    unless args[:to].blank?
      m.owner = m.receiver = User.find_by_username(args[:to])
      m.sender = sender
      m.created_at = Time.now
      m.subject = I18n.t('model.message.new.no_subject') if m.subject.blank?
      m.unread = true
      m.folder = INBOX
    end
    if !args[:message_id].blank? # if replying or forwarding
      old_message = find args[:message_id]
      old_message.ensure_ownership sender
      prepare_for_reply m, old_message if args[:reply]
      prepare_for_forward m, old_message if args[:forward]
    end
    m
  end

  def self.deliver_system_message(receiver)
    m = new
    m.owner = m.receiver = receiver
    m.sender = User.system_user
    m.created_at = Time.now
    m.unread = true
    m.folder = INBOX
    yield m
    m.deliver
  end

  def owned_by?(user)
    self.owner_id == user.id
  end

  def ensure_ownership(user)
    raise NotOwnerError unless owned_by? user
  end

  def set_read
    toggle! :unread if unread?
  end

  def deliver(replied_id = nil)
    if valid?
      delete_replied(replied_id) if replied_id && self.sender.delete_on_reply
      save
      save_sent if self.sender.save_sent?
      self.owner.toggle! :has_new_message unless self.owner.has_new_message?
      return true
    end
    false
  end

  def move_to_folder(folder, mover)
    ensure_ownership mover
    update_attribute :folder, folder
  end
  
  private

  def self.prepare_for_reply(m, old_message)
    m.subject = "#{ 'Re: ' unless old_message.subject.starts_with?('Re:') }#{old_message.subject}"
    m.body = "\n\n\n----
              \n#{old_message.sender.username} #{I18n.t('model.message.prepare_to_reply.wrote')}:
              \n\n#{old_message.body}"
    m.replying_to = old_message.sender.username
  end

  def self.prepare_for_forward(m, old_message)
    m.subject = "#{ 'Fwd: ' unless old_message.subject.starts_with?('Fwd:') }#{old_message.subject}"
    m.body = "\n\n\n----
             \n#{old_message.sender.username} #{I18n.t('model.message.prepare_to_forward.wrote')}:
             \n\n#{old_message.body}"
  end

  def delete_replied(replied_id)
    unless replied_id.blank?
      m = find replied_id
      m.ensure_ownership self.sender
      m.update_attribute :folder, TRASH
    end
  end

  def save_sent
    clone = self.clone
    clone.owner = self.sender
    clone.folder = SENT
    clone.save
  end
end
