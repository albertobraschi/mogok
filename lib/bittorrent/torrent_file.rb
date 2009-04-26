
module Bittorrent

  module TorrentFile
    extend Bcode

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
      attr_accessor :message
      attr_accessor :original
      
      def initialize(message, original)
        self.message, self.original = message, original
      end
    end

    def self.parse(torrent_data, logger = nil)
      begin
        parse_bencoded torrent_data
      rescue => e
        logger.debug ":-o Bittorrent::TorrentFile.parse - error: #{e.message}" if logger
        raise InvalidTorrentError.new('Invalid torrent file.', e)
      end
    end
  end
end





