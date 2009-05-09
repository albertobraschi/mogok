
class User < ActiveRecord::Base
  strip_attributes! # strip_attributes

  attr_protected :role_id, :tickets

  has_many :torrents, :dependent => :nullify
  has_many :peers, :dependent => :destroy
  has_many :bookmarks, :dependent => :destroy
  has_many :snatches, :dependent => :nullify
  has_many :comments, :dependent => :nullify
  has_many :messages, :foreign_key => 'owner_id', :dependent => :destroy
  has_many :invitations, :dependent => :destroy, :order => 'created_at DESC'
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

  def before_create
    self.role = Role.find_by_name(Role::USER) unless self.role
    self.created_at = Time.now
    self.reset_token
    self.reset_passkey
    self.style = Style.find(:first)
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

  def self.search(params, searcher, args)
    params[:username] = nil if params[:username] && params[:username].size < 3

    paginate :conditions => search_conditions(params, searcher),
             :order => search_order_by(params),
             :page => current_page(params[:page]),
             :per_page => args[:per_page]
  end

  def self.top_uploaders(args)
    find :all, :order => 'uploaded DESC', :conditions => 'uploaded > 0', :limit => args[:limit]
  end

  def self.top_contributors(args)
    a = []
    q = "SELECT user_id, COUNT(*) AS uploads FROM torrents WHERE user_id IS NOT NULL GROUP BY user_id ORDER BY uploads DESC LIMIT #{args[:limit]}"
    result = connection.select_all q
    result.each {|r| a << {:user => find(r['user_id']), :torrents => r['uploads']} }
    a
  end

  def self.find_absents(threshold)
    find :all, :conditions => ['last_seen_at < ? AND active = TRUE', threshold]
  end

  def self.update_user_counters(user, uploaded, downloaded)
    User.transaction do
      u = find user.id, :lock => true
      u.uploaded += uploaded
      u.downloaded += downloaded
      u.save
    end
  end

  def announce_passkey(torrent)
    hmac = CryptUtils.hmac_md5 torrent.announce_key, self.passkey
    hmac + self.id.to_s # append user id to hmac
  end

  def create_password_recovery
    code = User.make_password_recovery_code
    PasswordRecovery.delete_all_by_user self
    PasswordRecovery.create :created_at => Time.now, :code => code, :user => self
    code
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
    if updater != self && !updater.system_user?
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

  def save_sent?
    self.save_sent && !system_user?
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

  def reset_passkey!
    reset_passkey
    save
  end

  def reset_token
    self.token = CryptUtils.md5_token self.id, 20
  end

  def edit(params, updater, current_password)
    if set_attributes(params, updater, current_password)
      return save
    end
    false
  end

  def change_password(password, confirmation)
    self.password = password
    self.password_confirmation = confirmation
    save
  end

  def paginate_uploads(params, args)
    Torrent.scoped_by_active(true).paginate_by_user_id self,
                                                       :order => self.class.order_by(params[:order_by], params[:desc]),
                                                       :page => self.class.current_page(params[:page]),
                                                       :per_page => args[:per_page],
                                                       :include => :tags
  end

  def paginate_stuck(params, args)
    Torrent.paginate :conditions => stuck_conditions,
                     :order => 'leechers_count DESC, name',
                     :page => self.class.current_page(params[:page]),
                     :per_page => args[:per_page],
                     :include => :tags
  end


  def paginate_invitees(params, args)
    self.class.paginate_by_inviter_id self.id,
                                      :order => 'created_at',
                                      :page => self.class.current_page(params[:page]),
                                      :per_page => args[:per_page]
  end

  def paginate_messages(args)
    Message.paginate_by_owner_id self.id,
                                 :conditions => {:folder => args[:folder]},
                                 :order => 'created_at DESC',
                                 :page => args[:page],
                                 :per_page => args[:per_page]
  end

  def paginate_snatches(params, args)
    Snatch.paginate_by_user_id self,
                               :order => 'created_at DESC',
                               :page => self.class.current_page(params[:page]),
                               :per_page => args[:per_page]
  end

  def paginate_peers(params, args)
    Peer.paginate_by_user_id self,
                             :conditions => {:seeder => params[:seeding] == '1'},
                             :order => 'started_at DESC',
                             :page => self.class.current_page(params[:page]),
                             :per_page => args[:per_page]
  end
  
  private

  def self.search_conditions(params, searcher)
    s, h = '', {}
    unless searcher.system_user?
      s << 'id != 1 ' # hide system user
      previous = true
    end
    unless params[:username].blank?
      s << 'AND ' if previous
      s << 'username LIKE :username '
      h[:username] = "%#{params[:username]}%"
      previous = true
    end
    unless params[:role_id].blank?
      s << 'AND ' if previous
      s << 'role_id = :role_id '
      h[:role_id] = params[:role_id].to_i
      previous = true
    end
    unless params[:country_id].blank?
      s << 'AND ' if previous
      s << 'country_id = :country_id '
      h[:country_id] = params[:country_id].to_i
    end
    [s, h]
  end

  def self.search_order_by(params)
    if params[:order_by] == 'ratio'
      "uploaded/downloaded#{' DESC' if params[:desc] == '1'}"
    else
      order_by(params[:order_by], params[:desc])
    end
  end


  def stuck_conditions
    s, h = '', {}
    s << 'active = TRUE AND seeders_count = 0 AND leechers_count > 0 '
    s << 'AND '
    s << '(user_id = :user_id OR id IN (SELECT torrent_id FROM snatches WHERE user_id = :user_id))'
    h[:user_id] = self.id
    [s, h]
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

  def username_available?(params)
    User.find_by_username(params[:username], :conditions => ['id != ?', self.id]).blank?
  end

  def role_update_allowed?(params, updater)
    new_role = Role.find params[:role_id]
    if updater.system_user? || updater.owner?
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












