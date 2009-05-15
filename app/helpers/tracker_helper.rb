
module TrackerHelper

  protected

    def announce_url(passkey)
      unless APP_CONFIG[:tracker_url]
        tracker_url :action => 'announce', :passkey => passkey # check routes.rb
      else
        "#{APP_CONFIG[:tracker_url]}/#{passkey}/announce"
      end
    end
end
