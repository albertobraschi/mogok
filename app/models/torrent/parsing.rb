
class Torrent
  include Bittorrent::Bcode
  include Bittorrent::TorrentFile

  # parsing concern

  def out
    root = BDictionary.new
    root[ANNOUNCE] = BString.new(self.announce_url)
    root[CREATED_BY] = BString.new(self.created_by) if self.created_by
    root[COMMENT] = BString.new(self.comment) if self.comment
    root[CREATION_DATE] = BNumber.new(self.creation_date.to_i) if self.creation_date
    root[INFO] = BRaw.new(self.raw_info.data) # precooked info entry
    root.out
  end

  def set_meta_info(torrent_data, force_private = false, logger = nil)
    begin
      meta_info = parse(torrent_data, logger) # parse and check if meta-info is valid
      logger.debug ':-) torrent file is valid' if logger
    rescue InvalidTorrentError => e
      logger.debug ":-o torrent parsing error: #{e.message}" if logger
      valid? # check other errors
      add_error :torrent_file, 'invalid'
      return false
    end
    meta_info[INFO][PRIVATE] = '1' if force_private
    populate_meta_info meta_info
    true
  end

  private

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
end
