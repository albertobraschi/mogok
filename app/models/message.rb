
class Message < ActiveRecord::Base
  strip_attributes! # strip_attributes

  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  belongs_to :receiver, :class_name => 'User', :foreign_key => 'receiver_id'

  INBOX, OLDS, SENT, TRASH = 'inbox', 'olds', 'sent', 'trash'
  FOLDERS = [INBOX, OLDS, SENT, TRASH]

  validates_presence_of :receiver_id, :message => I18n.t('model.message.errors.receiver.invalid')
  validates_inclusion_of :folder, :in => FOLDERS, :message => 'invalid folder'

  def validate
    if self.receiver && !self.receiver.active?
      errors.add :receiver_id, I18n.t('model.message.errors.receiver.inactive')
    end
  end

  def before_save
    self.subject = self.subject[0, 50]
    self.body = self.body[0, 2000] if self.body
  end

  def self.valid_folder?(value)
    FOLDERS.include? value
  end

  def owned_by?(user)
    self.owner_id == user.id
  end

  def self.user_messages(user, params, *args)
    options = args.pop
    paginate_by_owner_id user,
                         :conditions => {:folder => options[:folder]},
                         :order => 'created_at DESC',
                         :page => current_page(params[:page]),
                         :per_page => options[:per_page]
  end
end
