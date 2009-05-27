
# GIVEN

Given /^I have a wish with name "(.*)" and owned by user "(.*)"$/ do |name, username|
  fetch_type 'audio'
  c = fetch_category 'music', 'audio'
  owner = fetch_user username
  Wish.create :category => c, :name => name, :user => owner
end

Given /^I have a wish bounty for wish "(.*)" with amount of (\d+) created by "(.*)"$/ do |wish_name, amount, username|
  w = Wish.find_by_name wish_name
  u = fetch_user username
  WishBounty.create :user => u, :wish => w, :amount => amount
end

Given /^wish "(.*)" was filled with torrent "(.*)"$/ do |name, torrent_name|
  w = Wish.find_by_name name
  t = Torrent.find_by_name torrent_name
  w.pending = true
  w.torrent = t
  w.filler = t.user
  w.filled_at = Time.now
  w.save
end

Given /^wish "(.*)" was filled and approved with torrent "(.*)"$/ do |name, torrent_name|
  w = Wish.find_by_name name
  t = Torrent.find_by_name torrent_name
  w.pending = false
  w.filled = true
  w.torrent = t
  w.filler = t.user
  w.filled_at = Time.now
  w.save
end

Given /^I have a comment by user "(.*)" for wish "(.*)" with body equal to "(.*)"$/ do |username, wish_name, body|
  w = Wish.find_by_name(wish_name)
  commenter = fetch_user username
  w.add_comment(body, commenter)
end


# THEN

Then /^a wish with name "(.*)" should be created$/ do |name|
  Wish.find_by_name(name).should_not be_nil
end

Then /^a wish_bounty with amount (\d+) should be created for wish "(.*)"$/ do |amount, wish_name|
  w = Wish.find_by_name(wish_name)
  WishBounty.find_by_wish_id_and_amount(w, amount.to_i).should_not be_nil
end

Then /^wish "(.*)" should have total bounty equal to (\d+)$/ do |name, total_bounty|
  Wish.find_by_name(name).total_bounty.should == total_bounty.to_i
end

Then /^wish "(.*)" should be set to filled$/ do |name|
  Wish.find_by_name(name).filled.should be_true
end

Then /^wish "(.*)" should be set to pending$/ do |name|
  Wish.find_by_name(name).pending.should be_true
end

Then /^wish "(.*)" should be set to not pending$/ do |name|
  Wish.find_by_name(name).pending.should == false
end

Then /^wish "(.*)" should have filler set to "(.*)"$/ do |name, filler|
  Wish.find_by_name(name).filler.should == fetch_user(filler)
end

Then /^wish "(.*)" should have torrent set to "(.*)"$/ do |name, torrent_name|
  Wish.find_by_name(name).torrent.should == Torrent.find_by_name(torrent_name)
  
end

Then /^filler for wish "(.*)" should be empty$/ do |name|
  Wish.find_by_name(name).filler.should be_nil
end

Then /^torrent for wish "(.*)" should be empty$/ do |name|
  Wish.find_by_name(name).torrent.should be_nil
end

Then /^a moderation report for wish "(.*)" with reason "(.*)" should be created$/ do |wish_name, reason|
  w = Wish.find_by_name(wish_name)
  label = Report.make_target_label(w)
  Report.find_by_target_label_and_reason(label, reason).should_not be_nil
end

Then /^a comment by user "(.*)" with body equal to "(.*)" should be created for wish "(.*)"$/ do |username, body, wish_name|
  w = Wish.find_by_name(wish_name)
  commenter = fetch_user username
  WishComment.find_by_user_id_and_body_and_wish_id(commenter, body, w).should_not be_nil
end





