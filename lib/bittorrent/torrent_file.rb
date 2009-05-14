
module Bittorrent

  module TorrentFile
    include Bcode

    INFO          = 'info'
    ANNOUNCE      = 'announce'
    COMMENT       = 'comment'
    CREATED_BY    = 'created by'
    CREATION_DATE = 'creation date'
    ENCODING      = 'encoding'
    FILES         = 'files'
    LENGTH        = 'length'
    PATH          = 'path'
    NAME          = 'name'
    PIECE_LENGTH  = 'piece length'
    PIECES        = 'pieces'
    PRIVATE       = 'private'

    class InvalidTorrentError < StandardError
    end

    def parse(torrent_data, logger = nil)
      begin
        meta_info = parse_bencoded(torrent_data)
      rescue => e
        logger.debug ":-o bittorrent::torrent_file.parse error: #{e.message} [#{e.backtrace[0]}]" if logger
        raise InvalidTorrentError.new('error while parsing')
      end
      check meta_info, logger
      meta_info
    end

    def check(meta_info, logger = nil)
      info = meta_info[INFO]
      begin        
        Time.at(meta_info[CREATION_DATE]) if meta_info[CREATION_DATE] # optional, just check format

        raise 'empty info[NAME]' unless value?(info[NAME])
        raise 'empty info[PIECE_LENGTH]' if info[PIECE_LENGTH].nil?
        raise 'empty info[PIECES]' unless value?(info[PIECES])

        unless value?(info[FILES]) # single file mode
          raise 'empty info[LENGTH] in single file mode' if info[LENGTH].nil?
        else
          info[FILES].each do |file|
            raise 'empty file[LENGTH]' if file[LENGTH].nil?
            file[PATH].each {|path| raise 'empty file[PATH]' unless value?(path) }
          end
        end
      rescue => e
        logger.debug ":-o bittorrent::torrent_file.check error: #{e.message} [#{e.backtrace[0]}]" if logger
        raise InvalidTorrentError.new('error while checking')
      end
    end

    private

      def value?(v)
        !v.nil? && !v.empty?
      end
  end
end





