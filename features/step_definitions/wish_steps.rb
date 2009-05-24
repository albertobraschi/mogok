
# GIVEN

Given /^I have a wish with name (.*) and owned by user (.*)$/ do |name, owner|
  fetch_type 'AUDIO'
  c = fetch_category 'MUSIC', 'AUDIO'
  owner = fetch_user owner
  Wish.create :category => c, :name => name, :user => owner
end

Given /^I have a wish_bounty for wish (.*) with amount of (\d+) created by (.*)$/ do |wish_name, amount, creator|
  w = Wish.find_by_name wish_name
  u = fetch_user creator
  WishBounty.create :user => u, :wish => w, :amount => amount
end

Given /^wish (.*) was filled with torrent (.*)$/ do |name, torrent_name|
  w = Wish.find_by_name name
  t = Torrent.find_by_name torrent_name
  w.pending = true
  w.torrent = t
  w.filler = t.user
  w.filled_at = Time.now
  w.save
end

Given /^wish (.*) was filled and approved with torrent (.*)$/ do |name, torrent_name|
  w = Wish.find_by_name name
  t = Torrent.find_by_name torrent_name
  w.pending = false
  w.filled = true
  w.torrent = t
  w.filler = t.user
  w.filled_at = Time.now
  w.save
end

# WHEN

When /^I go to the new wish page$/ do
  visit 'wishes/new'
end

When /^I go to the wish details page for wish (.*)$/ do |wish_name|
  w = Wish.find_by_name wish_name
  visit "wishes/show/#{w.id}"
end

When /^I go to the wish filling page for wish (.*)$/ do |wish_name|
  w = Wish.find_by_name wish_name
  visit "wishes/fill/#{w.id}"
end


# THEN

Then /^a wish with name (.*) should be created$/ do |name|
  Wish.find_by_name(name).should_not == nil
end

Then /^a wish_bounty with amount (\d+) should be created for wish (.*)$/ do |amount, wish_name|
  w = Wish.find_by_name(wish_name)
  WishBounty.find_by_wish_id_and_amount(w, amount.to_i).should_not == nil
end

Then /^wish with name (.*) should have total_bounty equal to (\d+)$/ do |name, total_bounty|
  Wish.find_by_name(name).total_bounty.should == total_bounty.to_i
end

Then /^wish with name (.*) should be set to filled$/ do |name|
  Wish.find_by_name(name).filled.should == true
end

Then /^wish with name (.*) should be set to pending$/ do |name|
  Wish.find_by_name(name).pending.should == true
end

Then /^wish with name (.*) should be set to not pending$/ do |name|
  Wish.find_by_name(name).pending.should == false
end

Then /^wish with name (.*) should have filler set to (.*)$/ do |name, filler|
  Wish.find_by_name(name).filler.should == fetch_user(filler)
end

Then /^wish with name (.*) should have torrent set to (.*)$/ do |name, torrent_name|
  Wish.find_by_name(name).torrent.should == Torrent.find_by_name(torrent_name)
  
end

Then /^filler for wish with name (.*) should be empty$/ do |name|
  Wish.find_by_name(name).filler.should == nil
end

Then /^torrent for wish with name (.*) should be empty$/ do |name|
  Wish.find_by_name(name).torrent.should == nil
end




