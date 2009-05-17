
module TrackerHelper
  include Bittorrent::Tracker

  protected

    def make_announce_url(torrent, user)
      external_url = APP_CONFIG[:tracker][:external_url]
      
      announce_passkey = make_announce_passkey(torrent, user)
      
      unless external_url
        tracker_url :action => 'announce', :passkey => announce_passkey
      else
        "#{external_url}/#{announce_passkey}/announce"
      end
    end
end
