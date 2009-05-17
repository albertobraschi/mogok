
include Bittorrent::Tracker

# GIVEN

Given /^the torrent (.*) has one seeding peer by user (.*) at ip (.*) and port (\d+)$/ do |torrent_name, username, ip, port|
  t = Torrent.find_by_name torrent_name
  u = fetch_user username
  fetch_peer t.id, u.id, ip, port, true
  t.update_attribute :seeders_count, 1
end

Given /^the torrent (.*) has one leeching peer by user (.*) at ip (.*) and port (\d+)$/ do |torrent_name, username, ip, port|
  t = Torrent.find_by_name torrent_name
  u = fetch_user username
  fetch_peer t.id, u.id, ip, port, false
end


# WHEN

When /^user (.*) sends a scrape request for torrent (.*)$/ do |username, torrent_name|
  t = Torrent.find_by_name torrent_name
  u = fetch_user username
  scrape_url = tracker_url(:action => 'scrape', :passkey => make_announce_passkey(t, u))
  get scrape_url, {:info_hash => t.info_hash}
end

When /^user (.*) sends an announce with event (.*) for torrent (.*)$/ do |username, event, torrent_name|
  @peers_count = Peer.count
  t = Torrent.find_by_name torrent_name
  @leechers_count = t.leechers_count
  @seeders_count = t.seeders_count
  u = fetch_user username
  announce_url = tracker_url(:action => 'announce', :passkey => make_announce_passkey(t, u))
  left = (event == 'completed') ? 0 : 12345
  get announce_url, {:info_hash => t.info_hash,
                     :compact => 0, # compact is 0 so we can analize the response
                     :port => 33333,
                     :peer_id => '-UT1770-------------',
                     :event => event,
                     :left => left,}
  
end

When /^user (.*) sends a no event announce for torrent (.*) with (\d+) uploaded and (\d+) downloaded$/ do |username, torrent_name, uploaded, downloaded|
  t = Torrent.find_by_name torrent_name
  u = fetch_user username
  @downloaded = u.downloaded
  @uploaded = u.uploaded
  announce_url = tracker_url(:action => 'announce', :passkey => make_announce_passkey(t, u))
  get announce_url, {:info_hash => t.info_hash,
                     :compact => 0,
                     :port => 33333,
                     :peer_id => '-UT1770-------------',
                     :left => 12345,
                     :uploaded => uploaded,
                     :downloaded => downloaded }

end


# THEN

Then /^a new peer should be added$/ do
  Peer.count.should == @peers_count + 1
end

Then /^one peer should be removed$/ do
  Peer.count.should == @peers_count - 1
end

Then /^the peer for torrent (.*) and user (.*) should be set to seeder$/ do |torrent_name, username|
  t = Torrent.find_by_name torrent_name
  u = fetch_user username
  peer = Peer.find :first, :conditions => ['torrent_id = ? AND user_id = ?', t, u]
  peer.seeder.should == true
end

Then /^the uploaded and downloaded counters for user (.*) should be increased in (\d+) and (\d+)/ do |username, uploaded, downloaded|
  u = fetch_user username
  u.uploaded.should == @uploaded + uploaded.to_i
  u.downloaded.should == @downloaded + downloaded.to_i
end


