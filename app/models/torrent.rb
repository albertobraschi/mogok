
class Torrent < ActiveRecord::Base
  concerns :callbacks, :finders, :logging, :notification, :parsing, :tracker, :validation

  strip_attributes! # strip_attributes plugin
  
  index [:info_hash_hex] # cache_money plugin

  has_many :mapped_files, :dependent => :destroy
  has_many :peers, :dependent => :destroy
  has_many :bookmarks, :dependent => :destroy
  has_many :snatches, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :rewards, :dependent => :destroy
  has_and_belongs_to_many :tags, :order => :name
  has_one :raw_info, :dependent => :destroy
  has_one :torrent_fulltext, :dependent => :destroy
  has_one :wish, :dependent => :destroy
  belongs_to :user
  belongs_to :category
  belongs_to :format
  belongs_to :country
  
  attr_accessor :announce_url
  attr_accessor :tags_str  
  attr_accessor :inactivated

  attr_accessor :bookmarked # flag used to indicate if the torrent is bookmarked

  def tags_str=(s)
    self.tags = Tag.parse_tags s
  end
  
  def bookmarked?
    self.bookmarked
  end

  def set_bookmarked(u)
    self.bookmarked = true if self.bookmarks.find_by_user_id u
  end

  def bookmark_unbookmark(u)
    b = self.bookmarks.find_by_user_id u
    if b
      b.destroy
      self.bookmarked = false
    else
      b = Bookmark.create :torrent => self, :user => u
      self.bookmarked = true
    end
  end
  
  def tags_str
    self.tags.join ', ' if self.tags
  end

  def inactivated?
    self.inactivated
  end

  def parse_and_save(torrent_data, force_private = false)
    if set_meta_info(torrent_data, force_private)
      if save
        log_upload
        return true
      end
    end
    false
  end

  def inactivate(inactivator, reason)
    self.inactivated = true # flag used by cache sweeper
    update_attribute(:active, false)
    log_inactivation(inactivator, reason)
    notify_inactivation(inactivator, reason) if self.user != inactivator
    logger.debug ':-) torrent inactivated'
  end

  def activate(activator)
    update_attribute :active, true
    log_activation(activator)
    notify_activation(activator) if self.user != activator
    logger.debug ':-) torrent activated'
  end

  def destroy_with_notification(destroyer, reason)
    destroy
    log_destruction(destroyer, reason)
    notify_destruction(destroyer, reason) if self.user != destroyer
    logger.debug ':-) torrent destroyed'
  end

  def report(reporter, reason, path)
    Report.create(self, reporter, reason, path)
  end

  def add_comment(body, commenter)
    Torrent.transaction do
      increment! :comments_count
      c = Comment.new :user => commenter, :torrent => self, :body => body
      c.comment_number = self.comments_count
      c.save
    end
  end

  def add_reward(amount, rewarder)
    Reward.create :torrent => self, :user => rewarder, :amount => amount
  end

  def editable_by?(user)
    user.id == self.user_id || user.admin_mod?
  end

  def edit(params, editor, reason)
    set_attributes params
    if save
      log_edition(editor, reason)
      return true
    end
    false
  end

  private

    def set_attributes(params)
      if self.name != params[:name]
        self.name = params[:name]
        @update_fulltext = true
      end
      self.category_id = params[:category_id]
      self.format_id = params[:format_id]
      self.tags = Tag.parse_tags params[:tags_str], self.category_id
      if self.description != params[:description]
        self.description = params[:description]
        @update_fulltext = true
      end
      self.year = params[:year]
      self.country_id = params[:country_id]
    end
end

