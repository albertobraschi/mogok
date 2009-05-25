
# GIVEN

Given /^I have a bookmark for torrent "(.*)" and user "(.*)"$/ do |torrent_name, username|
  t = Torrent.find_by_name(torrent_name)
  u = fetch_user username
  Bookmark.create(:torrent => t, :user => u)
end

# THEN

Then /^a bookmark for torrent "(.*)" and user "(.*)" should be created$/ do |torrent_name, username|
  t = Torrent.find_by_name(torrent_name)
  u = fetch_user username
  Bookmark.find_by_torrent_id_and_user_id(t, u).should_not be_nil
end

Then /^bookmark for torrent "(.*)" and user "(.*)" should be removed$/ do |torrent_name, username|
  t = Torrent.find_by_name(torrent_name)
  u = fetch_user username
  Bookmark.find_by_torrent_id_and_user_id(t, u).should be_nil
end