
class Torrent < ActiveRecord::Base
  concerns :finders, :parsing, :tracker, :validation

  strip_attributes! # strip_attributes
  
  index [:info_hash_hex] # cache_money

  has_many :mapped_files, :dependent => :destroy
  has_many :peers, :dependent => :destroy
  has_many :bookmarks, :dependent => :destroy
  has_many :snatches, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_and_belongs_to_many :tags, :order => :name
  has_one :raw_info, :dependent => :destroy
  has_one :torrent_fulltext, :dependent => :destroy
  belongs_to :user
  belongs_to :category
  belongs_to :format
  belongs_to :country
  
  attr_accessor :announce_url
  attr_accessor :tags_str
  attr_accessor :bookmarked
  attr_accessor :inactivated

  def before_create
    self.created_at = Time.now
    self.tags = Tag.parse_tags self.tags_str, self.category_id
    self.announce_key = CryptUtils.md5_token rand, 10    
    self.info_hash_hex = CryptUtils.hexencode self.info_hash
  end

  def before_save
    self.description = self.description[0, 10000] if self.description
  end
  
  def after_create
    TorrentFulltext.create :torrent => self, :body => "#{self.name} #{self.description}"
    logger.debug ':-) torrent created'
  end

  def after_update
    self.torrent_fulltext.update_attribute :body, "#{self.name} #{self.description}" if @update_fulltext
  end

  def after_destroy
    logger.debug ':-) torrent destroyed'
  end

  def tags_str=(s)
    self.tags = Tag.parse_tags s
  end
  
  def bookmarked?
    self.bookmarked
  end

  def set_bookmarked(u)
    self.bookmarked = true if self.bookmarks.find_by_user_id u
  end
  
  def tags_str
    self.tags.join ', ' if self.tags
  end

  def inactivated?
    self.inactivated
  end

  def inactivate
    self.inactivated = true # flag used by cache sweeper
    update_attribute :active, false
    logger.debug ':-) torrent inactivated'
  end

  def activate
    update_attribute :active, true
    logger.debug ':-) torrent activated'
  end

  def add_comment(params, user)
    Torrent.transaction do
      increment! :comments_count
      c = Comment.new :user => user,
                      :torrent => self,
                      :created_at => Time.now,
                      :body => params[:body]
      c.comment_number = self.comments_count
      c.save
    end
  end

  def editable_by?(user)
    user.id == self.user_id || user.admin_mod?
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
    self.tags = Tag.parse_tags params[:tags_str], self.category_id
    if self.description != params[:description]
      self.description = params[:description]
      @update_fulltext = true
    end
    self.year = params[:year]
    self.country_id = params[:country_id]
  end
end

