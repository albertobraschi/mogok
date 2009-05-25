
# GIVEN

Given /^I have a comment by user "(.*)" for torrent "(.*)" with body equal to "(.*)"$/ do |username, torrent_name, body|
  torrent = Torrent.find_by_name(torrent_name)
  commenter = fetch_user username
  torrent.add_comment(body, commenter)
end


# THEN

Then /^a comment by user "(.*)" with body equal to "(.*)" should be created for torrent "(.*)"$/ do |username, body, torrent_name|
  commenter = fetch_user username
  torrent = Torrent.find_by_name(torrent_name)
  Comment.find_by_user_id_and_body_and_torrent_id(commenter, body, torrent).should_not be_nil
end