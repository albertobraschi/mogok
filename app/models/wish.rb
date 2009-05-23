
class Wish < ActiveRecord::Base
  concerns :callbacks, :finders, :logging, :notification, :validation

  strip_attributes! # strip_attributes plugin

  has_many   :wish_bounties, :dependent => :destroy
  has_one    :wish_fulltext, :dependent => :destroy
  belongs_to :torrent
  belongs_to :user
  belongs_to :filler, :class_name => 'User'
  belongs_to :category
  belongs_to :format
  belongs_to :country

  def open?
    !filled? && !pending?
  end

  def self.has_pending?
    !find(:first, :conditions => {:pending => true}).blank?
  end

  def status
    case
      when filled?
        I18n.t('model.wish.status.filled')
      when pending?
        I18n.t('model.wish.status.pending')
      else
        I18n.t('model.wish.status.open')
    end
  end

  def add_comment(body, commenter)
    Wish.transaction do
      increment! :comments_count
      WishComment.create :user => commenter, :wish => self, :body => body, :comment_number => self.comments_count
    end
  end

  def add_bounty(amount, user)
    WishBounty.create :user => user, :wish => self, :amount => amount
  end

  def fill(t)
    self.pending = true
    self.torrent = t
    self.filler = self.torrent.user
    self.filled_at = Time.now
    save
  end

  def approve
    Wish.transaction do
      self.pending = false
      self.filled = true
      self.comments_locked = true
      self.save

      self.filler.lock!
      self.filler.uploaded += self.total_bounty
      self.filler.save
    end
    log_approval
    notify_approval
  end

  def reject(rejecter, reason)
    notify_rejection rejecter, reason

    self.pending = false
    self.torrent_id = nil
    self.filler_id = nil
    self.filled_at = nil
    save
  end

  def destroy_with_notification(destroyer, reason)
    Wish.transaction do
      notify_destruction if destroyer != self.user
      log_destruction destroyer, reason
      destroy
    end
  end

  def editable_by?(user)
    unless user.admin_mod?
      open? && user.id == self.user_id
    else
      true
    end
  end

  def edit(params)
    set_attributes params
    save
  end

  private

    def set_attributes(params)
      if self.name != params[:name]
        self.name = params[:name]
        @update_fulltext = true
      end
      self.category_id = params[:category_id]
      self.format_id = params[:format_id]
      if self.description != params[:description]
        self.description = params[:description]
        @update_fulltext = true
      end
      self.year = params[:year]
      self.country_id = params[:country_id]
    end
end

