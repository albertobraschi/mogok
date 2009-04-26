
class Torrent < ActiveRecord::Base
  include Bittorrent::Bcode
  include Bittorrent::TorrentFile

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

  validates_uniqueness_of :info_hash, :message => I18n.t('model.torrent.errors.info_hash.taken')
  validates_presence_of :name
  validates_presence_of :category_id

  MAX_TAGS = 4

  def validate
    errors.add(:tags, I18n.t('model.torrent.errors.tags.max', :max => MAX_TAGS)) if self.tags.length > MAX_TAGS
    errors.add(:year, I18n.t('model.torrent.errors.year.invalid')) if self.year && self.year.to_s.size != 4
  end

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
    TorrentFulltext.create :torrent_id => self.id, :body => "#{self.name} #{self.description}"
  end

  def after_update
    self.torrent_fulltext.update_attribute :body, "#{self.name} #{self.description}" if @update_fulltext
  end

  def editable_by?(user)
    user.id == self.user_id || user.admin_mod?
  end

  def tags_str=(s)
    self.tags = Tag.parse_tags s
  end

  def total_peers
    self.seeders_count + self.leechers_count
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
    self.inactivated = true # this flag is used by the torrents cache sweeper
    toggle! :active    
  end

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
  
  def out
    root = BDictionary.new
    root[ANNOUNCE] = BString.new(self.announce_url)
    root[CREATED_BY] = BString.new(self.created_by) if self.created_by
    root[COMMENT] = BString.new(self.comment) if self.comment
    root[CREATION_DATE] = BNumber.new(self.creation_date.to_i) if self.creation_date
    root[INFO] = BRaw.new(self.raw_info.data) # precooked info entry
    root.out
  end
  
  # Populate the torrent object with the given meta info hash.
  def set_meta_info(meta_info, force_private = false, logger = nil)
    begin
      meta_info[INFO][PRIVATE] = '1' if force_private
      populate_meta_info meta_info
    rescue => e
      logger.debug ":-o Torrent.set_meta_info error: #{e.message}" if logger
      raise InvalidTorrentError.new('Invalid torrent file.', e)
    end
  end
  
  private

  def populate_meta_info(meta_info)
    self.creation_date = Time.at(meta_info[CREATION_DATE].to_i) unless meta_info[CREATION_DATE].blank?
    self.created_by = meta_info[CREATED_BY]
    self.comment = meta_info[COMMENT][0, 100] unless meta_info[COMMENT].blank?
    self.encoding = meta_info[ENCODING]

    info = meta_info[INFO]
    self.piece_length = info[PIECE_LENGTH]
    self.mapped_files = []
    if info[FILES].blank? # single file mode
      self.mapped_files << MappedFile.new(:name => info[NAME], :length => info[LENGTH])
      self.size = info[LENGTH]
      self.files_count = 1
    else
      self.dir_name = info[NAME]
      size = 0      
      info[FILES].each do |file|
        file_path = file_name = ''         
        file[PATH].each do |path| # path comes splited in a list
          if path == file[PATH].last
            file_name = path # last path item is the filename
          else
            file_path << path << '/'
          end
        end
        self.mapped_files << MappedFile.new(:name => file_name, :length => file[LENGTH], :path => file_path)
        size += file[LENGTH]
      end
      self.size = size
      self.files_count = info[FILES].size      
    end

    self.raw_info = RawInfo.new :data => make_info_entry(meta_info[INFO])
    self.info_hash = CryptUtils.sha1_digest self.raw_info.data
  end

  # Make the complete INFO entry so it can be kept ready to go, avoiding extra work
  # when a torrent file is generated.
  def make_info_entry(info)
    root = BDictionary.new

    if info[FILES].blank? # single file mode
      root[LENGTH] = BNumber.new(info[LENGTH])
    else
      files_list = BList.new
      info[FILES].each do |info_file|
        file = BDictionary.new
        file[LENGTH] = BNumber.new(info_file[LENGTH])
        file_path_list = BList.new
        info_file[PATH].each {|info_file_path| file_path_list << BString.new(info_file_path) }
        file[PATH] = file_path_list
        files_list << file
      end
      root[FILES] = files_list
    end    
    root[NAME] = BString.new(info[NAME])
    root[PIECE_LENGTH] = BNumber.new(info[PIECE_LENGTH])
    root[PIECES] = BString.new(info[PIECES])
    root[PRIVATE] = BNumber.new(info[PRIVATE]) if info[PRIVATE] == '1'
    root.out
  end
end

