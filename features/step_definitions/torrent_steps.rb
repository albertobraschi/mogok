
# GIVEN

Given /^I have a torrent with name "(.*)" and owned by user "(.*)"$/ do |name, uploader|
  make_torrent find_user(uploader), name
end

Given /^I uploaded a torrent with name "(.*)"$/ do |name|
  Given "I have a category with name \"music\" and with type \"audio\""
  When "I go to the torrent upload page"
  And "I select \"music\" from \"torrent_category_id\""
  And "I fill file field \"torrent_file\" with \"valid.torrent\""
  And "I fill in \"torrent_name\" with \"#{name}\""
  And "I press \"Upload\""
end

Given /^torrent "(.*)" is inactive$/ do |name|
  t = find_torrent(name)
  t.active = false
  t.save
end

Given /^torrent "(.*)" has snatches_count equal to (\d+)$/ do |name, snatches_count|
  t = find_torrent(name)
  t.snatches_count = snatches_count
  t.save
end

Given /^the counters for torrent "(.*)" indicate (\d+) seeders and (\d+) leechers$/ do |name, seeders, leechers|
  t = find_torrent(name)
  t.seeders_count = seeders
  t.leechers_count = leechers
  t.save
end

Given /^I have a comment by user "(.*)" for torrent "(.*)" with body equal to "(.*)"$/ do |username, torrent_name, body|
  torrent = find_torrent(torrent_name)
  commenter = find_user username
  torrent.add_comment(body, commenter)
end


# THEN

Then /^the downloaded torrent file should have same info hash as torrent "(.*)"$/ do |torrent_name|
  downloaded_torrent = Torrent.new
  downloaded_torrent.set_meta_info(response.body, false) # false because it should contain the private flag already
  downloaded_torrent.info_hash.should == find_torrent(torrent_name).info_hash
end

Then /^torrent "(.*)" should have (\d+) mapped files$/ do |name, mapped_files_number|
  find_torrent(name).mapped_files.size.should == mapped_files_number.to_i
end

Then /^torrent "(.*)" should have (\d+) as piece length$/ do |name, piece_length|
  find_torrent(name).piece_length.should == piece_length.to_i
end

Then /^torrent "(.*)" should have (\d+) tags$/ do |name, tags_number|
  find_torrent(name).tags.length.should == tags_number.to_i
end

Then /^torrent "(.*)" should have total reward equal to (\d+)$/ do |name, total_reward|
  find_torrent(name).total_reward.should == total_reward.to_i
end

Then /^torrent "(.*)" should have seeders equal to (\d+)$/ do |name, seeders|
  find_torrent(name).seeders_count.should == seeders.to_i
end

Then /^torrent "(.*)" should have leechers equal to (\d+)$/ do |name, leechers|
  find_torrent(name).leechers_count.should == leechers.to_i
end

Then /^a moderation report for torrent "(.*)" with reason "(.*)" should be created$/ do |torrent_name, reason|
  t = find_torrent(torrent_name)
  label = Report.make_target_label(t)
  r = Report.find_by_target_label_and_reason(label, reason)
  r.should_not be_nil
  r.target_path.should == torrents_path(:action => 'show', :id => t)
end

Then /^torrent "(.*)" should be inactive$/ do |name|
  find_torrent(name).active?.should be_false
end

Then /^torrent "(.*)" should be active$/ do |name|
  find_torrent(name).active?.should be_true
end

Then /^torrent "(.*)" should be deleted$/ do |name|
  find_torrent(name).should be_nil
end

Then /^a comment by user "(.*)" with body equal to "(.*)" should be created for torrent "(.*)"$/ do |username, body, torrent_name|
  commenter = find_user username
  torrent = find_torrent(torrent_name)
  Comment.find_by_user_id_and_body_and_torrent_id(commenter, body, torrent).should_not be_nil
end





