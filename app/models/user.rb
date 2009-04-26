
class User < ActiveRecord::Base
  strip_attributes! # strip_attributes

  attr_protected :role_id, :tickets

  has_many :torrents, :dependent => :nullify
  has_many :peers, :dependent => :destroy
  has_many :bookmarks, :dependent => :destroy
  has_many :snatches, :dependent => :nullify
  has_many :comments, :dependent => :nullify
  has_many :messages, :foreign_key => 'owner_id', :dependent => :destroy
  has_many :invitations, :dependent => :destroy
  has_many :invitees, :class_name => 'User', :foreign_key => 'inviter_id', :dependent => :nullify
  has_many :announce_logs, :dependent => :destroy
  has_many :password_recoveries, :dependent => :destroy
  has_many :topics, :dependent => :nullify
  has_many :posts, :dependent => :nullify
  belongs_to :role
  belongs_to :country
  belongs_to :gender
  belongs_to :style
  belongs_to :inviter, :class_name => 'User', :foreign_key => 'inviter_id'

  EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  validates_presence_of :username, :message => I18n.t('model.user.errors.username.required')
  validates_uniqueness_of :username, :on => :create, :case_sensitive => false, :message => I18n.t('model.user.errors.username.taken')
  validates_length_of :username, :minimum => 3, :too_short => I18n.t('model.user.errors.username.invalid_length')
  validates_length_of :username, :maximum => 20, :too_long => I18n.t('model.user.errors.username.invalid_length')
  validates_presence_of :email, :message => I18n.t('model.user.errors.email_required')
  validates_uniqueness_of :email, :on => :create, :case_sensitive => false, :message => I18n.t('model.user.errors.email.taken')
  validates_format_of :email, :with => EMAIL_FORMAT, :message => I18n.t('model.user.errors.email.invalid')

  attr_accessor :password_confirmation
  attr_reader :password

  def before_save
    self.info = self.info[0, 4000] if self.info
  end

  def before_destroy
    raise ArgumentError if self.id == 1
  end

  def validate
    if self.encrypted_password.blank?
      errors.add :password, I18n.t('model.user.errors.password.required')
    elsif self.password
      if self.password.size < 5
        errors.add :password, I18n.t('model.user.errors.password.too_short')
      elsif self.password != self.password_confirmation
        errors.add :password_confirmation, I18n.t('model.user.errors.password.invalid_confirmation')
      end
    end
  end
      
  def self.authenticate(username, password)
    u = self.find_by_username username
    if u && u.encrypted_password == CryptUtils.encrypt_password(password, u.salt)
      return u
    end
    nil
  end

  def self.valid_email?(email)
    email =~ EMAIL_FORMAT
  end
  
  def self.make_invite_code
    CryptUtils.md5_token '', 20
  end

  def self.make_password_recovery_code
    CryptUtils.md5_token
  end

  def self.system_user
    find 1
  end

  def announce_passkey(torrent)
    hmac = CryptUtils.hmac_md5 torrent.announce_key, self.passkey
    hmac + self.id.to_s # append user id to hmac
  end

  def password=(password)
    @password = password
    unless password.blank?
      self.salt = CryptUtils.md5_token object_id
      self.encrypted_password = CryptUtils.encrypt_password @password, self.salt
    end
  end

  def slide_token_expiration(limit_period)
    if self.token_expires_at <= limit_period.minutes.from_now
      self.token_expires_at = limit_period.minutes.from_now
    end
  end
  
  def editable_by?(updater)
    unless updater == self || updater.system_user?
      if updater.owner?
        return false if system_user? || owner? # owner: all but system and owners
      elsif updater.admin?
        return false if admin? # admin: all but admins and above
      else
        return false # others: only themselves
      end
    end
    true
  end

  def system_user?
    self.role.system?
  end

  def owner?
    self.role.owner?
  end

  def admin?
    self.role.admin?
  end

  def admin_mod?
    self.role.admin? || self.role.mod?
  end

  def mod?
    self.role.mod?
  end

  def has_ticket?(ticket)
    self.role.has_ticket?(ticket) || (self.tickets && self.tickets.split(' ').include?(ticket.to_s))
  end  

  def ratio
    if self.downloaded != 0
      self.uploaded / self.downloaded.to_f
    else
      0
    end
  end
  
  def reset_passkey
    self.passkey = CryptUtils.md5_token self.username
  end

  def reset_token
    self.token = CryptUtils.md5_token self.id, 20
  end

  def set_attributes(params, updater, current_password)
    self.country_id = params[:country_id]
    self.style_id = params[:style_id]
    self.gender_id = params[:gender_id]
    self.avatar = params[:avatar]
    self.info = params[:info]
    self.save_sent = params[:save_sent]
    self.delete_on_reply = params[:delete_on_reply]
    self.display_last_seen_at = params[:display_last_seen_at]
    self.display_downloads = params[:display_downloads]

    if self.email != params[:email]
      self.email = params[:email]
      unless email_available?(params)
        errors.add(:email, I18n.t('model.user.errors.email.taken'))
        return false
      end
    end

    unless updater.admin?
      if current_password.blank?
        errors.add(:current_password, I18n.t('model.user.errors.password.required'))
        return false
      else
        unless self.encrypted_password == CryptUtils.encrypt_password(current_password, self.salt)
          errors.add(:current_password, I18n.t('model.user.errors.password.incorrect'))
          return false      
        end
      end
    else
      if self.username != params[:username]
        self.username = params[:username]
        unless username_available?(params)
          errors.add(:username, I18n.t('model.user.errors.username.taken'))
          return false
        end        
      end
      if self.role_id != params[:role_id].to_i && role_update_allowed?(params, updater)
        self.role_id = params[:role_id]
      end
      self.tickets = params[:tickets]
      self.active = params[:active] if self.id != 1
      self.staff_info = params[:staff_info]     
      self.uploaded, self.downloaded = params[:uploaded], params[:downloaded] if params[:update_stats] == '1'
    end

    unless params[:password].blank?
      self.password = params[:password]        
      self.password_confirmation = params[:password_confirmation]
    end

    return true
  end
  
  private

  def username_available?(params)
    User.find_by_username(params[:username], :conditions => ['id != ?', self.id]).blank?
  end

  def role_update_allowed?(params, updater)
    new_role = Role.find params[:role_id]
    if updater.system? || updater.owner?
      return false if new_role.system?
    elsif updater.admin?
      return false if new_role.reserved?
    else
      return false
    end
    true
  end

  def email_available?(params)
    User.find_by_email(params[:email], :conditions => ['id != ?', self.id]).blank?
  end
end












