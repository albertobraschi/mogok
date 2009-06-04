
module Bittorrent

  class AnnounceRequest

    STARTED   = 'started'
    STOPPED   = 'stopped'
    COMPLETED = 'completed'

    # params collected from the client request
    attr_accessor :event, :ip, :port
    attr_accessor :downloaded, :uploaded, :left
    attr_accessor :passkey, :peer_id, :info_hash
    attr_accessor :numwant, :no_peer_id, :compact, :key

    # application info
    attr_accessor :torrent, :user, :client, :seeder
    attr_accessor :current_action_at, :last_action_at
    attr_accessor :up_offset, :down_offset

    def started?
      self.event == STARTED
    end

    def stopped?
      self.event == STOPPED
    end

    def completed?
      self.event == COMPLETED
    end

    def set_numwant(n)
      self.numwant = n if self.numwant > n || self.numwant == 0
    end

    def seeder?
      self.seeder
    end

    def set_offsets(previous_uploaded, previous_downloaded)
      if self.uploaded > previous_uploaded
        self.up_offset = self.uploaded - previous_uploaded # amount uploaded since last announce
      end
      if self.downloaded > previous_downloaded
        self.down_offset = self.downloaded - previous_downloaded
      end
    end

    def initialize(params)
      self.passkey     = params[:passkey]
      self.event       = params[:event]
      self.info_hash   = params[:info_hash]
      self.numwant     = params[:numwant].to_i
      self.port        = params[:port].to_i
      self.uploaded    = params[:uploaded].to_i
      self.downloaded  = params[:downloaded].to_i
      self.left        = params[:left].to_i
      self.peer_id     = params[:peer_id]
      self.no_peer_id  = true if params[:no_peer_id] == '1'
      self.compact     = true if params[:compact] == '1'
      self.key         = params[:key]
      self.down_offset = 0
      self.up_offset   = 0
      self.seeder      = completed? || self.left == 0
    end

    def valid?
      case
        when self.event == COMPLETED && self.left != 0
          false
        when self.info_hash.blank? || self.port.blank? || self.peer_id.blank?
          false
        else
          true
      end
    end

    def attributes
      h = {}
      h[:torrent]           = self.torrent
      h[:user]              = self.user      
      h[:event]             = self.event
      h[:ip]                = self.ip
      h[:port]              = self.port
      h[:uploaded]          = self.uploaded
      h[:downloaded]        = self.downloaded
      h[:left]              = self.left
      h[:seeder]            = self.seeder
      h[:passkey]           = self.passkey
      h[:peer_id]           = self.peer_id
      h[:info_hash]         = self.info_hash
      h[:numwant]           = self.numwant
      h[:no_peer_id]        = self.no_peer_id
      h[:compact]           = self.compact
      h[:key]               = self.key
      h[:up_offset]         = self.up_offset
      h[:down_offset]       = self.down_offset
      h[:peer_id]           = self.peer_id
      h[:last_action_at]    = self.last_action_at
      h[:current_action_at] = self.current_action_at
      h[:client]            = self.client
      h[:time_interval]     = self.current_action_at.to_i - self.last_action_at.to_i if self.last_action_at
      h
    end
  end
end


