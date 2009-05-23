require 'ipaddr'
require 'openssl'

module Bittorrent

  module Tracker

    protected

      def make_announce_passkey(torrent, user)
        hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::MD5.new, torrent.announce_key, user.passkey).upcase
        hmac + user.id.to_s
      end

      def parse_user_id_from_announce_passkey(passkey)
        begin
          passkey.size > 32 ? Integer(passkey[32, passkey.size - 1]) : nil
        rescue
          nil
        end
      end
      
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
        logger.debug ":-) tracker.exec_announce: event = [#{req.event}]"
        req.current_action_at = Time.now

        peer = Peer.find_peer(req.torrent, req.user, req.ip, req.port)
        
        unless peer
          Peer.create(req) unless req.stopped?
        else
          req.set_offsets(peer.uploaded, peer.downloaded)
          req.user.increment_counters(req.up_offset, req.down_offset)
          unless req.stopped?
            req.torrent.add_snatch(req.user) if req.completed?
            req.last_action_at = peer.last_action_at
            peer.refresh_announce(req)
          else
            peer.destroy
          end          
        end
        AnnounceLog.create(req) if log_announce
        prepare_resp(req, resp) unless req.stopped?
      end

    private

      def prepare_resp(req, resp)
        resp.complete = req.torrent.seeders_count
        resp.incomplete = req.torrent.leechers_count
        resp.compact = req.compact
        resp.no_peer_id = req.no_peer_id
        resp.peers = Peer.find_for_announce_resp(req.torrent, req.user, req.numwant)
      end
  end
end


  