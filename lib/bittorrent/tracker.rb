require 'ping'
require 'ipaddr'

module Bittorrent

  module Tracker

    protected

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

        peer = Peer.find_peer req.torrent, req.user, req.ip, req.port

        if peer
          calculate_offsets req, peer
          unless req.stopped?
            register_snatch req if req.completed?
            update_peer peer, req
          else
            destroy_peer peer
          end
          update_user_counters req
        else
          create_peer req unless req.stopped?
        end

        AnnounceLog.create req if log_announce

        prepare_resp req, resp unless req.stopped?
      end

    private

      def create_peer(req)
        logger.debug ':-) create peer'
        p = Peer.new
        p.init_attributes req
        set_peer_connectivity p
        p.save
        req.torrent = p.torrent
      end

      def update_peer(p, req)
        logger.debug ':-) update peer'
        req.last_action_at = p.last_action_at
        p.set_attributes req
        set_peer_connectivity p
        p.save
      end

      def destroy_peer(p)
        logger.debug ':-) destroy peer'
        p.destroy
      end

      def set_peer_connectivity(p)
        # orphaned peer_conns are wiped by a background task
        if p.new_record?
          peer_conn = PeerConn.find_peer_conn(p.ip, p.port)
          p.peer_conn = peer_conn || PeerConn.new(:ip => p.ip, :port => p.port)
        end
        if p.peer_conn.connectable.nil? # also in case an existing peer_conn is still nil due to timeouted
          p.peer_conn.connectable = Ping.pingecho p.peer_conn.ip, 5, p.peer_conn.port # nil if timeouted
          p.peer_conn.save
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

      def update_user_counters(req)
        if req.up_offset > 0 || req.down_offset > 0
          req.user.update_counters req.up_offset, req.down_offset
        end
      end

      def register_snatch(req)
        snatch = Snatch.create req.torrent, req.user
        req.torrent = snatch.torrent
        logger.debug ':-) torrent snatch registered'
      end

      def prepare_resp(req, resp)
        resp.complete = req.torrent.seeders_count
        resp.incomplete = req.torrent.leechers_count
        set_resp_peers req, resp
      end

      def set_resp_peers req, resp
        resp.peers = Peer.find_for_announce_resp req.torrent, req.user, :limit => req.numwant
        resp.compact = req.compact
        resp.no_peer_id = req.no_peer_id
      end
  end
end