

module Bittorrent

  class AnnounceResponse
    include Bcode

    FAILURE_REASON  = 'failure reason'
    WARNING_MESSAGE = 'warning message'
    INTERVAL        = 'interval'
    MIN_INTERVAL    = 'min interval'
    TRACKER_ID      = 'tracker id'
    COMPLETE        = 'complete'
    INCOMPLETE      = 'incomplete'
    PEERS           = 'peers'
    PEER_ID         = 'peer id'
    PEER_IP         = 'ip'
    PEER_PORT       = 'port'

    attr_accessor :failure_reason, :warning_message
    attr_accessor :interval, :min_interval, :tracker_id
    attr_accessor :complete, :incomplete
    attr_accessor :peer_id, :info_hash
    attr_accessor :numwant, :no_peer_id, :compact, :key
    attr_accessor :compact_ip, :no_peer_id, :peers

    def out(logger = nil)
      logger.debug ':-) announce_response.out' if logger
      root = BDictionary.new
      if self.failure_reason
        root[FAILURE_REASON] = BString.new(self.failure_reason)
      else
        root[WARNING_MESSAGE] = BString.new(self.warning_message) if self.warning_message
        root[INTERVAL] = BNumber.new(self.interval)
        root[MIN_INTERVAL] = BNumber.new(self.min_interval) if self.min_interval > 0
        root[TRACKER_ID] = BString.new(self.tracker_id) if self.tracker_id
        root[COMPLETE] = BNumber.new(self.complete)
        root[INCOMPLETE] = BNumber.new(self.incomplete)
        if self.peers && self.peers.size > 0
          if self.compact
            logger.debug ':-) client supports compact ip extension' if logger
            compact_ips = ''
            self.peers.each do |p|
              if p.compact_ip
                compact_ips << p.compact_ip
                logger.debug ":-) peer [#{p.ip}, #{p.port}] included in response in compact format" if logger
              end
            end
            root[PEERS] = BString.new(compact_ips)
          else
            logger.debug ':-) client does not support compact ip extension' if logger
            b_peers = BList.new
            self.peers.each do |p|
              b_peer = BDictionary.new
              b_peer[PEER_ID] = BString.new(p.peer_id) unless self.no_peer_id
              b_peer[PEER_IP] = BString.new(p.ip)
              b_peer[PEER_PORT] = BNumber.new(p.port)
              b_peers << b_peer
              logger.debug ":-) peer [#{p.ip}, #{p.port}] included in response in plain format" if logger
            end
            root[PEERS] = b_peers
          end
        else
          root[PEERS] = BString.new # just the empty entry
        end
      end
      r = root.out
      logger.debug ":-) announce response: #{r}" if logger
      r
    end
  end
end
