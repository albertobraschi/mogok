
module Bittorrent

  class AnnounceRequest

    STARTED   = 'started';
    STOPPED   = 'stopped';
    COMPLETED = 'completed';

    # params that come in the request
    attr_accessor :event, :ip, :port
    attr_accessor :downloaded, :uploaded, :left
    attr_accessor :peer_id, :info_hash
    attr_accessor :numwant, :no_peer_id, :compact, :key

    # application info
    attr_accessor :torrent, :passkey, :user, :client, :seeder
    attr_accessor :current_action, :last_action_at
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

    def initialize(params)
      self.passkey = params[:passkey]
      self.event = params[:event]
      self.info_hash = params[:info_hash]
      self.numwant = params[:numwant].to_i
      self.port = params[:port].to_i
      self.uploaded = params[:uploaded].to_i
      self.downloaded = params[:downloaded].to_i
      self.left = params[:left].to_i
      self.peer_id = params[:peer_id]
      self.no_peer_id = true if params[:no_peer_id] == '1'
      self.compact = true if params[:compact] == '1'
      self.key = params[:key]
      self.down_offset = 0
      self.up_offset = 0
      self.seeder = completed? || self.left == 0
    end

    def valid?
      return false if self.event == COMPLETED && self.left != 0
      return false if self.info_hash.blank? || self.port.blank? || self.peer_id.blank?
      true
    end
  end
end