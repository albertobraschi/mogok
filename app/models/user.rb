

class User < ActiveRecord::Base
  concerns :authentication, :authorization, :password_recovery, :signup
  concerns :callbacks, :finders, :validation
  concerns :tracker

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

  def register_access
    if self.last_request_at.blank? || self.last_request_at < 3.minutes.ago
      update_attribute :last_request_at, Time.now
    end
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def save_sent?
    self.save_sent && !system_user?
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

  def edit(params, updater, current_password)
    if set_attributes(params, updater, current_password)
      return save
    end
    false
  end

  private

    def set_attributes(params, updater, current_password)
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

    def email_available?(params)
      User.find_by_email(params[:email], :conditions => ['id != ?', self.id]).blank?
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
end












