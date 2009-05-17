
module TrackerHelper

  protected

    def announce_url(passkey)
      external_url = APP_CONFIG[:tracker][:external_url]
      
      unless external_url
        tracker_url :action => 'announce', :passkey => passkey # check routes.rb
      else
        "#{external_url}/#{passkey}/announce"
      end
    end
end
