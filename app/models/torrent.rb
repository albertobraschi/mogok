
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
  validates_numericality_of :year, :message => I18n.t('model.torrent.errors.year.invalid'), :allow_blank => true
  validates_presence_of :name
  validates_presence_of :category_id


  MAX_TAGS = 4

  def validate
    errors.add(:tags, I18n.t('model.torrent.errors.tags.max', :max => MAX_TAGS)) if self.tags.length > MAX_TAGS
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
    TorrentFulltext.create :torrent_id => self, :body => "#{self.name} #{self.description}"
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
    self.inactivated = true # flag used by cache sweeper
    update_attribute :active, false
  end

  def activate
    update_attribute :active, true
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

  def paginate_comments(params, args)
    Comment.paginate_by_torrent_id self,
                                   :order => 'created_at',
                                   :page => self.class.current_page(params[:page]),
                                   :per_page => args[:per_page]
  end

  def paginate_peers(params, args)
    Peer.paginate_by_torrent_id self,
                                :order => 'started_at DESC',
                                :page => self.class.current_page(params[:page]),
                                :per_page => args[:per_page]
  end


  def paginate_snatches(params, args)
    Snatch.paginate_by_torrent_id self,
                                  :order => 'created_at DESC',
                                  :page => self.class.current_page(params[:page]),
                                  :per_page => args[:per_page]
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
  
  def edit(params)
    set_attributes params
    save
  end

  def set_meta_info(torrent_data, force_private = false, logger = nil)
    begin
      meta_info = parse(torrent_data, logger) # parse and check if meta-info is valid
      logger.debug ':-) torrent file is valid' if logger
    rescue InvalidTorrentError => e
      logger.debug ":-o torrent parsing error: #{e.message}" if logger
      errors.add :torrent_file, I18n.t('model.torrent.errors.torrent_file.invalid')
      return false
    end
    meta_info[INFO][PRIVATE] = '1' if force_private
    populate_meta_info meta_info
    true
  end

  def self.search(params, searcher, args)
    paginate :conditions => search_conditions(params, searcher),
             :order => order_by(params[:order_by], params[:desc]),
             :page => current_page(params[:page]),
             :per_page => args[:per_page],
             :include => :tags
  end

  def self.stuck_by_user(user, params, args)
    paginate :conditions => stuck_conditions(user),
             :order => 'leechers_count DESC, name',
             :page => current_page(params[:page]),
             :per_page => args[:per_page],
             :include => :tags
  end

  def self.bookmarked_by_user(user, params, args)
    paginate :conditions => bookmarked_by_user_conditions(user),
             :order => 'category_id, name',
             :page => current_page(params[:page]),
             :per_page => args[:per_page],
             :include => :tags
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

  def populate_meta_info(meta_info)
    self.creation_date = Time.at(meta_info[CREATION_DATE]) unless meta_info[CREATION_DATE].blank?
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
    root[PRIVATE] = BNumber.new(info[PRIVATE]) if info[PRIVATE]
    root.out
  end

  def self.search_conditions(params, searcher)
    s, h = '', {}
    if searcher.admin_mod?
      if params[:inactive] == '1'
        s << 'active = FALSE '
        previous = true
      end
    else
      s << 'active = TRUE '
      previous = true
    end
    unless params[:keywords].blank?
      s << 'AND ' if previous
      s << 'id IN (SELECT torrent_id FROM torrent_fulltexts WHERE MATCH(body) AGAINST (:keywords IN BOOLEAN MODE)) '
      h[:keywords] = params[:keywords]
      previous = true
    end
    unless params[:category_id].blank?
      s << 'AND ' if previous
      s << 'category_id = :category_id '
      h[:category_id] = params[:category_id].to_i
      previous = true
    end
    unless params[:format_id].blank?
      s << 'AND ' if previous
      s << 'format_id = :format_id '
      h[:format_id] = params[:format_id].to_i
      previous = true
    end
    unless params[:country_id].blank?
      s << 'AND ' if previous
      s << 'country_id = :country_id '
      h[:country_id] = params[:country_id].to_i
      previous = true
    end
    unless params[:tags_str].blank?
      if params[:category_id].blank?
        params[:tags_str] = ''
      else
        tags = Tag.parse_tags params[:tags_str], params[:category_id].to_i
        unless tags.blank?
          if tags.length > 3
            tags = tags[0, 3] # three tags maximum
          end
          params[:tags_str] = tags.join ', ' # show user which tags were used in search
          s << 'AND ' if previous
          s << 'id IN '
          s << "(SELECT torrent_id FROM tags_torrents WHERE tag_id = #{tags[0].id} "
          unless tags[1].blank?
            s << "AND torrent_id IN (SELECT torrent_id FROM tags_torrents WHERE tag_id = #{tags[1].id} "
            unless tags[2].blank?
              s << "AND torrent_id IN (SELECT torrent_id FROM tags_torrents WHERE tag_id = #{tags[2].id})"
            end
            s << ')'
          end
          s << ')'
        end
      end
    end
    [s, h]
  end

  def self.stuck_conditions(user)
    s, h = '', {}
    s << 'active = TRUE AND seeders_count = 0 AND leechers_count > 0 '
    s << 'AND '
    s << '(user_id = :user_id OR id IN (SELECT torrent_id FROM snatches WHERE user_id = :user_id))'
    h[:user_id] = user.id
    [s, h]
  end

  def self.bookmarked_by_user_conditions(user)
    s, h = '', {}
    unless user.admin_mod?
      s << 'active = TRUE '
      previous = true
    end
    s << 'AND ' if previous
    s << 'id in (SELECT torrent_id FROM bookmarks WHERE user_id = :user_id)'
    h[:user_id] = user.id
    [s, h]
  end
end

