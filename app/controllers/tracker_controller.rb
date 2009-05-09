
class TrackerController < ApplicationController
  include Bittorrent::Tracker

  class TrackerFailure < StandardError
  end

  def scrape
    logger.debug ':-) tracker_controller.scrape'
    resp = Bittorrent::ScrapeResponse.new
    begin
      failure 'not_allowed' unless APP_CONFIG[:tracker_scrape_enabled]
      begin
        req = Bittorrent::ScrapeRequest.new params
      rescue
        failure 'malformed_request'
      end
      
      set_torrent req, req.info_hashs[0] # only one torrent allowed due to the passkey validation (usually clients send only one info_hash anyway)
      set_user req

      exec_scrape req, resp
    rescue TrackerFailure => e
      resp.failure_reason = t(e.message)
    rescue => e
      log_error e
      resp.failure_reason = t('server_error')
    end
    send_data resp.out(logger), :type => 'text/plain'
  end
  
  def announce
    logger.debug ':-) tracker_controller.announce'
    resp = Bittorrent::AnnounceResponse.new
    begin      
      begin
        req = Bittorrent::AnnounceRequest.new params
      rescue
        failure 'malformed_request'
      end     

      set_torrent req
      set_user req

      req.ip = request.remote_ip
      req.set_numwant APP_CONFIG[:tracker_announce_resp_max_peers]
      req.client = parse_client req.peer_id, APP_CONFIG[:tracker_ban_unknown_clients]      

      if !req.valid?
        failure 'invalid_request'
      elsif req.client.banned?
        failure 'client_banned'
      elsif req.client.banned_version?
        failure 'client_version_banned'
      end      
        
      exec_announce req, resp, APP_CONFIG[:tracker_log_announces]
        
      resp.interval = APP_CONFIG[:tracker_announce_interval_seconds]
      resp.min_interval = APP_CONFIG[:tracker_announce_min_interval_seconds]
    rescue TrackerFailure => e
      resp.failure_reason = t(e.message)
    rescue => e
      log_error e
      resp.failure_reason = t('server_error')
    end
    send_data resp.out(logger), :type => 'text/plain'
  end

  private

  def set_torrent(req, info_hash = nil)
    req.torrent = Torrent.find_by_info_hash_hex(CryptUtils.hexencode(info_hash || req.info_hash)) # hex because memcached has problems with binary keys
    if req.torrent && req.torrent.active?
      logger.debug ":-) valid torrent: #{req.torrent.id} [#{req.torrent.name}]"
    else
      logger.debug ":-o torrent not found for info hash hex #{CryptUtils.hexencode(info_hash || req.info_hash)}"
      failure 'invalid_torrent'
    end
  end

  def set_user(req)        
    req.user = User.find_by_id parse_user_id(req.passkey)
    if req.user && req.user.active?
      logger.debug ":-) valid user: #{req.user.id} [#{req.user.username}]"
      if req.user.announce_passkey(req.torrent) != req.passkey
        logger.debug ":-o invalid announce passkey: #{req.passkey}"
        failure 'invalid_passkey'
      end
    else
      logger.debug ':-o user not found or inactive'
      failure 'invalid_user'
    end
    logger.debug ':-) valid announce passkey'
  end
  
  def failure(error_key)
    raise TrackerFailure.new(error_key)
  end

  def parse_user_id(announce_passkey)
    announce_passkey[32, announce_passkey.size - 1]
  end
end
