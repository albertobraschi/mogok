
# GIVEN

Given /^I have a torrent with name "(.*)" and owned by user "(.*)"$/ do |name, owner|
  if CACHE_ENABLED
    while t = Torrent.find_by_info_hash_hex('54B1A5052B5B7D3BA4760F3BFC1135306A30FFD1')
      t.destroy # force remotion of torrent objects from cache as the test framework bypass cache_money synchronization
    end
  end
  fetch_type 'AUDIO'
  c = fetch_category 'MUSIC', 'AUDIO'
  owner = fetch_user owner
  torrent_file_data = File.new(File.join(TEST_DATA_DIR, 'VALID.TORRENT'), 'rb').read
  t = Torrent.new(:category => c, :name => name, :user => owner)  
  t.parse_and_save owner, torrent_file_data, true
end


# THEN

Then /^the downloaded torrent file should have same info hash as torrent "(.*)"$/ do |torrent_name|
  downloaded_torrent = Torrent.new
  downloaded_torrent.set_meta_info(response.body, false) # false because it should contain the private flag already
  downloaded_torrent.info_hash.should == Torrent.find_by_name(torrent_name).info_hash
end

Then /^the torrent "(.*)" should have (\d+) mapped files$/ do |name, mapped_files|
  Torrent.find_by_name(name).mapped_files.size.should == mapped_files.to_i
end

Then /^the torrent "(.*)" should have (\d+) as piece length$/ do |name, piece_length|
  Torrent.find_by_name(name).piece_length.should == piece_length.to_i
end

Then /^the torrent "(.*)" should have (\d+) tags$/ do |name, tags|
  Torrent.find_by_name(name).tags.length.should == tags.to_i
end



