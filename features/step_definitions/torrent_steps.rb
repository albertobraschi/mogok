
# GIVEN

Given /^I have a torrent with name "(.*)" and owned by user "(.*)"$/ do |name, owner|
  if CACHE_ENABLED
    while t = Torrent.find_by_info_hash_hex('54B1A5052B5B7D3BA4760F3BFC1135306A30FFD1')
      t.destroy # force remotion of torrent objects from cache as the test framework bypass cache_money synchronization
    end
  end
  fetch_type 'audio'
  c = fetch_category 'music', 'audio'
  owner = fetch_user owner
  torrent_file_data = File.new(File.join(TEST_DATA_DIR, 'valid.torrent'), 'rb').read
  t = Torrent.new(:category => c, :name => name, :user => owner)  
  t.parse_and_save owner, torrent_file_data, true
end

Given /^torrent "(.*)" is inactive$/ do |name|
  t = Torrent.find_by_name(name)
  t.active = false
  t.save
end


# THEN

Then /^the downloaded torrent file should have same info hash as torrent "(.*)"$/ do |torrent_name|
  downloaded_torrent = Torrent.new
  downloaded_torrent.set_meta_info(response.body, false) # false because it should contain the private flag already
  downloaded_torrent.info_hash.should == Torrent.find_by_name(torrent_name).info_hash
end

Then /^torrent "(.*)" should have (\d+) mapped files$/ do |name, mapped_files|
  Torrent.find_by_name(name).mapped_files.size.should == mapped_files.to_i
end

Then /^torrent "(.*)" should have (\d+) as piece length$/ do |name, piece_length|
  Torrent.find_by_name(name).piece_length.should == piece_length.to_i
end

Then /^torrent "(.*)" should have (\d+) tags$/ do |name, tags|
  Torrent.find_by_name(name).tags.length.should == tags.to_i
end

Then /^torrent "(.*)" should have total reward equal to (\d+)$/ do |name, total_reward|
  Torrent.find_by_name(name).total_reward.should == total_reward.to_i
end

Then /^a moderation report for torrent "(.*)" with reason "(.*)" should be created$/ do |torrent_name, reason|
  t = Torrent.find_by_name(torrent_name)
  label = Report.make_target_label(t)
  Report.find_by_target_label_and_reason(label, reason).should_not be_nil
end

Then /^torrent "(.*)" should be inactive$/ do |name|
  Torrent.find_by_name(name).active?.should be_false
end

Then /^torrent "(.*)" should be active$/ do |name|
  Torrent.find_by_name(name).active?.should be_true
end

Then /^torrent "(.*)" should be removed$/ do |name|
  Torrent.find_by_name(name).should be_nil
end







