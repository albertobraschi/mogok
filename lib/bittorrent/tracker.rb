require 'ping'
require 'ipaddr'

module Bittorrent

  module Tracker

    def parse_client(peer_id, ban_unknown = false)
      if peer_id.size == 20
        if peer_id[0, 1] == '-' && peer_id[7, 1] == '-' # azureus style
          code = peer_id[1, 2]
          version = peer_id[3, 4]
        else # shadow style
          code = peer_id[0, 1]
          version = peer_id[1, 5].gsub('-', '')
        end
        c = Client.find_by_code code
      end
      unless c
        c = Client.new :code => code, :name => code
        c.banned = true if ban_unknown
      end
      c.version = version
      c
    end

    def exec_scrape(req, resp)
      logger.debug ':-) tracker.exec_scrape'
      req.torrents.each do |t|
        resp.add_file(t.info_hash, t.seeders_count, t.leechers_count, t.snatches_count)
      end
    end

    def exec_announce(req, resp, log_announce = true)
      logger.debug ':-) tracker.exec_announce'
      logger.debug ":-) event: #{req.event}"

      req.current_action = Time.now      

      p = Peer.find :first,
                    :conditions => {:torrent_id => req.torrent.id, :user_id => req.user.id, :ip => req.ip, :port => req.port}
      unless p
        logger.debug ':-) new peer'
        create_peer req, resp unless req.stopped?
      else
        logger.debug ':-) peer already exists'
        update_peer p, req, resp
      end

      AnnounceLog.create req if log_announce
      
      include_peers_in_response req, resp unless req.stopped?
    end

    private

    def create_peer(req, resp)
      p = Peer.new
      p.set_attributes req
      p.started_at = Time.now      
      set_peer_connectivity p
      p.save
      resp.complete = p.torrent.seeders_count
      resp.incomplete = p.torrent.leechers_count
      logger.debug ':-) peer created'
    end

    def update_peer(p, req, resp)
      req.last_action_at = p.last_action_at      
      if req.started?
        p.started_at = Time.now
      elsif req.stopped?
        destroy_peer p
      elsif req.completed?
        register_snatch req
      else
        # no event, just routine announce
      end
      calculate_offsets req, p
      unless req.stopped?
        p.set_attributes req
        set_peer_connectivity p
        p.save
        resp.complete = req.torrent.seeders_count
        resp.incomplete = req.torrent.leechers_count
      end      
      update_user_counters req
    end

    def destroy_peer(p)
      p.destroy
      logger.debug ':-) peer deleted'
    end

    def set_peer_connectivity(p)
      # orphaned peer_conns are wiped by a background task
      if p.new_record?
        peer_conn = PeerConn.find :first, :conditions => {:ip => p.ip, :port => p.port}        
        p.peer_conn = peer_conn || PeerConn.new(:ip => p.ip, :port => p.port)
      end
      if p.peer_conn.connectable.nil? # also in case an existing peer_conn is still nil due to timeouted
        p.peer_conn.connectable = Ping.pingecho p.peer_conn.ip, 5, p.peer_conn.port # nil if timeouted
        p.peer_conn.save
      end
    end

    def update_user_counters(req)
      if req.up_offset > 0 || req.down_offset > 0
        User.transaction do
          u = User.find req.user.id, :lock => true
          u.uploaded += req.up_offset
          u.downloaded += req.down_offset
          u.save
        end
      end
    end

    # calculate how much was uploaded and downloaded since the last announce
    def calculate_offsets(req, peer)
      if req.uploaded > peer.uploaded
        req.up_offset = req.uploaded - peer.uploaded
      end
      if req.downloaded > peer.downloaded
        req.down_offset = req.downloaded - peer.downloaded
      end
    end

    def register_snatch(req)
      Torrent.transaction do
        Snatch.create :user => req.user, :torrent => req.torrent, :created_at => Time.now
        t = Torrent.find req.torrent.id, :lock => true
        t.increment :snatches_count
        t.increment :seeders_count
        t.decrement :leechers_count if t.leechers_count > 0
        t.save
        req.torrent = t
      end
      logger.debug ':-) torrent snatch registered'
    end

    def include_peers_in_response req, resp
      cols = [:id, :torrent_id, :user_id, :uploaded, :downloaded, :leftt, :ip, :port, :started_at, :last_action_at]
      resp.peers = Peer.find :all,
                             :conditions => ['torrent_id = ? AND user_id != ?', req.torrent.id, req.user.id],
                             :order => cols.rand, # simple way to randomize retrieved peers
                             :limit => req.numwant
      resp.compact = req.compact
      resp.no_peer_id = req.no_peer_id
    end
  end
end