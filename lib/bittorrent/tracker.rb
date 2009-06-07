require 'ipaddr'
require 'openssl'

module Bittorrent

  module Tracker

    class TrackerFailure < StandardError
    end

    protected

      # Make an announce passkey. It is composed by the 32 characters hmac generated from the torrent
      # announce key and the user passkey followed by the user id.
      def make_announce_passkey(torrent, user)
        hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::MD5.new, torrent.announce_key, user.passkey).upcase
        hmac + user.id.to_s
      end

      # Just get the user id that is in the end of the announce passkey, after the hmac.
      def parse_user_id_from_announce_passkey(passkey)
        begin
          passkey.size > 32 ? Integer(passkey[32, passkey.size - 1]) : nil
        rescue
          nil
        end
      end

      # Returns a stored Client object or, if code not found in the database, an instance of
      # Client containing the code and version received.
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

      def process_scrape(params, config)
        logger.debug ':-) tracker.process_scrape'
        resp = ScrapeResponse.new
        begin
          failure 'not_allowed' unless config[:scrape_enabled]
          begin
            req = ScrapeRequest.new params
          rescue
            failure 'malformed_request'
          end

          set_torrent req, req.info_hashs[0] # only the first torrent is considered
          set_user req

          t = req.torrent
          resp.add_file(t.info_hash, t.seeders_count, t.leechers_count, t.snatches_count)          
        rescue TrackerFailure => e
          resp.failure_reason = i18n("scrape_announce.#{e.message}")
        rescue => e
          log_error e
          resp.failure_reason = i18n('process_scrape.server_error')
        end
        resp.out(logger)
      end

      def process_announce(params, remote_ip, config)
        logger.debug ":-) tracker.process_announce: event = [#{params[:event]}]"
        resp = AnnounceResponse.new
        begin
          begin
            req = AnnounceRequest.new params
          rescue
            failure 'malformed_request'
          end
          
          prepare_announce_req req, remote_ip, config

          check_announce_req_validity req

          process_announce_data req, config

          prepare_announce_resp req, resp, config
        rescue TrackerFailure => e
          resp.failure_reason = i18n("process_announce.#{e.message}")
        rescue => e
          log_error e
          resp.failure_reason = i18n('process_announce.server_error')
        end
        resp.out(logger)
      end

    private

      def failure(error_key)
        raise TrackerFailure.new(error_key)
      end

      def i18n(key)
        I18n.t("lib.bittorrent.tracker.#{key}")
      end

      def prepare_announce_req(req, remote_ip, config)
        req.ip = remote_ip
        set_torrent req
        set_user req
        req.set_numwant config[:announce_resp_max_peers]
        req.client = parse_client req.peer_id, config[:ban_unknown_clients]
      end

      def set_torrent(req, info_hash = nil)
        info_hash_hex = CryptUtils.hexencode(info_hash || req.info_hash)

        req.torrent = Torrent.find_by_info_hash_hex(info_hash_hex) # hex because memcached has problems with binary keys

        if req.torrent && req.torrent.active?
          logger.debug ":-) valid torrent: #{req.torrent.id} [#{req.torrent.name}]"
        else
          failure 'invalid_torrent'
          logger.debug ":-o torrent not found or inactive for info hash hex #{info_hash_hex}"
        end
      end

      def set_user(req)
        req.user = User.find_by_id(parse_user_id_from_announce_passkey(req.passkey))
        if req.user && req.user.active?
          logger.debug ":-) valid user: #{req.user.id} [#{req.user.username}]"
          if req.passkey != make_announce_passkey(req.torrent, req.user)
            failure 'invalid_passkey'
            logger.debug ":-o invalid announce passkey: #{req.passkey}"
          end
        else
          failure 'invalid_user'
          logger.debug ':-o user not found or inactive'
        end
        logger.debug ':-) valid announce passkey'
      end

      def check_announce_req_validity(req)
        case
          when !req.valid?
            failure 'invalid_request'
          when req.client.banned?
            failure 'client_banned'
          when req.client.banned_version?
            failure 'client_version_banned'
        end
      end

      def process_announce_data(req, config)
        req.current_action_at = Time.now

        peer = Peer.find_peer(req.torrent, req.user, req.ip, req.port)
        
        unless peer
          Peer.create(req.attributes) unless req.stopped?
        else
          req.last_action_at = peer.last_action_at
          req.set_offsets(peer.uploaded, peer.downloaded)          
          increment_user_counters(req, config[:bonus_rules])
          unless req.stopped?
            req.torrent.add_snatch(req.user) if req.completed?            
            peer.refresh_announce(req.attributes)
          else
            peer.destroy
          end          
        end
        AnnounceLog.create(req.attributes) if config[:log_announces]
      end

      def increment_user_counters(req, bonus_rules)
        up_offset = req.up_offset
        if req.seeder? && bonus_rules[:seeding]
          up_offset += (req.up_offset * bonus_rules[:seeding]).to_i # bonus for seeding
        end
        req.user.increment_counters(up_offset, req.down_offset)
      end

      def prepare_announce_resp(req, resp, config)
        resp.interval     = config[:announce_interval_seconds]
        resp.min_interval = config[:announce_min_interval_seconds]
        resp.complete     = req.torrent.seeders_count
        resp.incomplete   = req.torrent.leechers_count
        unless req.stopped?
          resp.compact      = req.compact
          resp.no_peer_id   = req.no_peer_id
          resp.peers = Peer.find_for_announce_resp(req.torrent, req.user, req.numwant)
        end
      end
  end
end


  