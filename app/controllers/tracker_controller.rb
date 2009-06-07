
class TrackerController < ApplicationController
  include Bittorrent::Tracker

  def scrape
    logger.debug ':-) tracker_controller.scrape'
    send_data(process_scrape(params, APP_CONFIG[:tracker]), :type => 'text/plain')
  end
  
  def announce
    logger.debug ':-) tracker_controller.announce'
    send_data(process_announce(params, request.remote_ip, APP_CONFIG[:tracker]), :type => 'text/plain')
  end
end




  
