

class User < ActiveRecord::Base
  concerns :authentication, :authorization, :callbacks, :finders, :logging, :notification
  concerns :pass_recovery, :ratio_policy, :signup, :tasks, :tracker, :validation

  strip_attributes! # strip_attributes plugin
  
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
  has_many :wishes, :dependent => :nullify
  has_many :filled_wishes, :class_name => 'Wish', :foreign_key => 'filler_id', :dependent => :nullify
  has_many :wish_bounties, :dependent => :nullify
  belongs_to :role
  belongs_to :country
  belongs_to :gender
  belongs_to :style
  belongs_to :inviter, :class_name => 'User', :foreign_key => 'inviter_id'

  # I18n shortcut
  def self.t(key, args = {})
    I18n.t("model.user.#{key}", args)
  end

  def register_access
    if self.last_request_at.blank? || self.last_request_at < 3.minutes.ago
      update_attribute :last_request_at, Time.now
    end
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def inactivate
    update_attribute :active, false
  end

  def activate
    update_attribute :active, true
  end

  def destroy_with_log(destroyer)
    destroy
    log_destruction(destroyer)
    logger.debug ':-) user destroyed'
  end

  def report(reporter, reason, path)
    Report.create(self, reporter, reason, path)
  end

  def editable_by?(updater)
    if updater != self && !updater.system?
      if updater.owner?
        return false if system? || owner? # owner: all but system and owners
      elsif updater.admin?
        return false if admin? # admin: all but admins and above
      else
        return false # others: only themselves
      end
    end
    true
  end

  def edit(params, updater, current_password, update_counters = false)
    if set_attributes(params, updater, current_password, update_counters)
      return save
    end
    false
  end

  private

    def set_attributes(params, updater, current_password, update_counters = false)
      self.country_id = params[:country_id]
      self.style_id = params[:style_id]
      self.gender_id = params[:gender_id]
      self.avatar = params[:avatar]
      self.info = params[:info]
      self.save_sent = params[:save_sent]
      self.delete_on_reply = params[:delete_on_reply]
      self.display_last_request_at = params[:display_last_request_at]
      self.display_downloads = params[:display_downloads]

      if self.email != params[:email]
        self.email = params[:email]
        unless email_available?(params)
          add_error :email, 'taken'
          return false
        end
      end

      unless updater.admin?
        if current_password.blank?
          add_error :current_password, 'required'
          return false
        else
          unless authenticated?(current_password)
            add_error :current_password, 'incorrect'
            return false
          end
        end
      else
        if self.username != params[:username]
          self.username = params[:username]
          unless username_available?(params)
            add_error :username, 'taken'
            return false
          end
        end
        if !system? && self.role_id != params[:role_id].to_i
          self.role_id = params[:role_id]
          unless role_update_allowed?(params, updater)
            errors.add :role_id, 'forbidden assignment' # happens of with html form tampering, no need to i18n
            return false
          end
        end
        self.tickets = params[:tickets]
        self.active = params[:active] if self.id != 1
        self.staff_info = params[:staff_info]
        self.ratio_watch_until = params[:ratio_watch_until]
        if update_counters
          self.uploaded = params[:uploaded]
          self.downloaded = params[:downloaded]
          self.ratio = calculate_ratio # tracker concern
        end
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

    def email_available?(params)
      User.find_by_email(params[:email], :conditions => ['id != ?', self.id]).blank?
    end

    def role_update_allowed?(params, updater)
      new_role = Role.find params[:role_id]
      if updater.system? || updater.owner?
        return false if new_role.system? # system and owners can assign any role unless 'system'
      elsif updater.admin?
        return false if new_role.reserved? # admins can assign only non-reserved roles
      else
        return false
      end
      true
    end
end












