
include Bittorrent::Tracker

# GIVEN

Given /^the torrent "(.*)" has one seeding peer by user "(.*)" at IP "(.*)" and port (\d+)$/ do |torrent_name, username, ip, port|
  t = Torrent.find_by_name torrent_name
  u = fetch_user username
  fetch_peer t, u, ip, port, true
  t.update_attribute :seeders_count, 1
end

Given /^the torrent "(.*)" has one leeching peer by user "(.*)" at IP "(.*)" and port (\d+)$/ do |torrent_name, username, ip, port|
  t = Torrent.find_by_name torrent_name
  u = fetch_user username
  fetch_peer t, u, ip, port, false
end

Given /^the counters for torrent "(.*)" indicate (\d+) seeders and (\d+) leechers$/ do |name, seeders, leechers|
  t = Torrent.find_by_name name
  t.seeders_count = seeders
  t.leechers_count = leechers
  t.save
end

Given /^the torrent "(.*)" has been snatched (\d+) times$/ do |name, snatched|
  t = Torrent.find_by_name name
  t.snatches_count = snatched
  t.save
end


# WHEN

When /^user "(.*)" sends a scrape request for torrent "(.*)"$/ do |username, torrent_name|
  t = Torrent.find_by_name torrent_name
  u = fetch_user username
  scrape_url = tracker_url(:action => 'scrape', :passkey => make_announce_passkey(t, u))
  get scrape_url, {:info_hash => t.info_hash}
end

When /^user "(.*)" sends an announce with event "(.*)" for torrent "(.*)"$/ do |username, event, torrent_name|
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

When /^user "(.*)" sends a no event announce for torrent "(.*)" with (\d+) uploaded and (\d+) downloaded$/ do |username, torrent_name, uploaded, downloaded|
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

Then /^a new peer should be created/ do
  Peer.count.should == @peers_count + 1
end

Then /^one peer should be deleted/ do
  Peer.count.should == @peers_count - 1
end

Then /^the leechers counter for torrent "(.*)" should be increased by one$/ do |torrent_name|
  Torrent.find_by_name(torrent_name).leechers_count.should == @leechers_count + 1
end

Then /^the leechers counter for torrent "(.*)" should be decreased by one$/ do |torrent_name|
  Torrent.find_by_name(torrent_name).leechers_count.should == @leechers_count - 1
end

Then /^the seeders counter for torrent "(.*)" should be increased by one$/ do |torrent_name|
  Torrent.find_by_name(torrent_name).seeders_count.should == @seeders_count + 1
end

Then /^the peer for torrent "(.*)" and user "(.*)" should be set to seeder$/ do |torrent_name, username|
  t = Torrent.find_by_name torrent_name
  u = fetch_user username
  peer = Peer.find_by_torrent_id_and_user_id(t, u)
  peer.seeder.should be_true
end

Then /^the uploaded and downloaded counters for user "(.*)" should be increased in (\d+) and (\d+)/ do |username, uploaded, downloaded|
  u = fetch_user username
  u.uploaded.should == @uploaded + uploaded.to_i
  u.downloaded.should == @downloaded + downloaded.to_i
end

Then /^a snatch for torrent "(.*)" and user "(.*)" should be created$/ do |torrent_name, username|
  t = Torrent.find_by_name torrent_name
  u = fetch_user username
  snatch = Snatch.find_by_torrent_id_and_user_id(t, u)
  snatch.should_not be_nil
end
