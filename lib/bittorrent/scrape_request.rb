
module Bittorrent
  
  class ScrapeRequest
    attr_accessor :info_hashs, :passkey, :user
    
    attr_accessor :torrents

    def torrent=(t)
      self.torrents = [t]
    end

    def torrent
      self.torrents[0] if self.torrents
    end

    def max_torrents=(n)
      if self.info_hashs && self.info_hashs.size > n
        self.info_hashs.slice! 0, n
      end
    end

    def initialize(params)
      self.passkey = params[:passkey]
      info_hash = params[:info_hash]
      case info_hash
        when String
          self.info_hashs = [info_hash]
        when Array
          self.info_hashs = info_hash
        else
          self.info_hashs = []
      end
    end
  end
end