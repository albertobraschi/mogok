
include Bittorrent::Tracker

# GIVEN

Given /^I have one seeding peer for torrent "(.*)" by user "(.*)" at IP "(.*)" and port (\d+)$/ do |torrent_name, username, ip, port|
  make_peer find_torrent(torrent_name), find_user(username), ip, port, true
end

Given /^I have one leeching peer for torrent "(.*)" by user "(.*)" at IP "(.*)" and port (\d+)$/ do |torrent_name, username, ip, port|
  make_peer find_torrent(torrent_name), find_user(username), ip, port, false
end


# WHEN

When /^user "(.*)" sends a scrape request for torrent "(.*)"$/ do |username, torrent_name|
  t = find_torrent torrent_name
  u = find_user username
  scrape_url = tracker_url(:action => 'scrape', :passkey => make_announce_passkey(t, u))
  get scrape_url, {:info_hash => t.info_hash}
end
       
When /^user "(.*)" sends an announce with event "(.*)" for torrent "(.*)" using port (\d+)$/ do |username, event, torrent_name, port|
  t = find_torrent torrent_name
  u = find_user username
  announce_url = tracker_url(:action => 'announce', :passkey => make_announce_passkey(t, u))  
  get announce_url, {:info_hash => t.info_hash,
                     :compact => 0, # so we get a non binary peers data
                     :port => port,
                     :peer_id => '-UT1770-------------',
                     :event => event,
                     :left => (event == 'completed') ? 0 : t.size }
end

When /^user "(.*)" sends an announce with zero left and event started for torrent "(.*)" using port (\d+)$/ do |username, torrent_name, port|
  t = find_torrent torrent_name
  u = find_user username
  announce_url = tracker_url(:action => 'announce', :passkey => make_announce_passkey(t, u))
  get announce_url, {:info_hash => t.info_hash,
                     :compact => 0, # so we get a non binary peers data
                     :port => port,
                     :peer_id => '-UT1770-------------',
                     :event => 'started',
                     :left => 0 }
end

When /^user "(.*)" sends an announce with no event for torrent "(.*)" with (\d+) uploaded and (\d+) downloaded using port (\d+)$/ do |username, torrent_name, uploaded, downloaded, port|
  t = find_torrent torrent_name
  u = find_user username
  announce_url = tracker_url(:action => 'announce', :passkey => make_announce_passkey(t, u))  
  get announce_url, {:info_hash => t.info_hash,
                     :compact => 0, # so we get a non binary peers data
                     :port => port,
                     :peer_id => '-UT1770-------------',
                     :event => '',
                     :left => t.size - downloaded.to_i,
                     :uploaded => uploaded,
                     :downloaded => downloaded }
end


# THEN
         
Then /^a new leeching peer for torrent "(.*)" by user "(.*)" at IP "(.*)" and port (\d+) should be created$/ do |torrent_name, username, ip, port|
  t = find_torrent torrent_name
  u = find_user username
  Peer.find_by_torrent_id_and_user_id_and_ip_and_port_and_seeder(t, u, ip, port, false).should_not be_nil
end

Then /^a new seeding peer for torrent "(.*)" by user "(.*)" at IP "(.*)" and port (\d+) should be created$/ do |torrent_name, username, ip, port|
  t = find_torrent torrent_name
  u = find_user username
  Peer.find_by_torrent_id_and_user_id_and_ip_and_port_and_seeder(t, u, ip, port, true).should_not be_nil
end

Then /^the peer for torrent "(.*)" by user "(.*)" at IP "(.*)" and port (\d+) should be removed$/ do |torrent_name, username, ip, port|
  t = find_torrent torrent_name
  u = find_user username
  Peer.find_by_torrent_id_and_user_id_and_ip_and_port(t, u, ip, port).should be_nil
end

Then /^the peer for torrent "(.*)" and user "(.*)" at IP "(.*)" and port (\d+) should be set to seeder$/ do |torrent_name, username, ip, port|
  t = find_torrent torrent_name
  u = find_user username
  Peer.find_by_torrent_id_and_user_id_and_ip_and_port(t, u, ip, port).seeder.should be_true
end

Then /^a snatch for torrent "(.*)" and user "(.*)" should be created$/ do |torrent_name, username|
  t = find_torrent torrent_name
  u = find_user username
  Snatch.find_by_torrent_id_and_user_id(t, u).should_not be_nil
end



