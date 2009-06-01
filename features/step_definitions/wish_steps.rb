
# given

  Given /^I have a wish with name "(.*)" and created by user "(.*)"$/ do |name, username|
    make_wish find_user(username), name
  end

  Given /^I have a wish bounty for wish "(.*)" with amount of (\d+) created by "(.*)"$/ do |wish_name, amount, username|
    find_wish(wish_name).add_bounty amount, find_user(username)
  end

  Given /^wish "(.*)" was filled with torrent "(.*)"$/ do |name, torrent_name|
    find_wish(name).fill find_torrent(torrent_name)
  end

  Given /^wish "(.*)" was filled and approved with torrent "(.*)"$/ do |name, torrent_name|
    w = find_wish name
    w.fill find_torrent(torrent_name)
    w.approve
  end

  Given /^I have a comment by user "(.*)" for wish "(.*)" with body equal to "(.*)"$/ do |username, wish_name, body|
    find_wish(wish_name).add_comment body, find_user(username)
  end

# when

  When /^I fill info_hash field with info hash hex for torrent "(.*)"$/ do |torrent_name|
    fill_in('info_hash', :with => find_torrent(torrent_name).info_hash_hex)
  end

# then

  Then /^a wish with name "(.*)" should be created$/ do |name|
    find_wish(name).should_not be_nil
  end

  Then /^a wish_bounty with amount (\d+) should be created for wish "(.*)"$/ do |amount, wish_name|
    w = find_wish(wish_name)
    WishBounty.find_by_wish_id_and_amount(w, amount.to_i).should_not be_nil
  end

  Then /^wish "(.*)" should have total bounty equal to (\d+)$/ do |name, total_bounty|
    find_wish(name).total_bounty.should == total_bounty.to_i
  end

  Then /^wish "(.*)" should be set to filled$/ do |name|
    find_wish(name).filled.should be_true
  end

  Then /^wish "(.*)" should be set to pending$/ do |name|
    find_wish(name).pending.should be_true
  end

  Then /^wish "(.*)" should be set to not pending$/ do |name|
    find_wish(name).pending.should == false
  end

  Then /^wish "(.*)" should have filler set to "(.*)"$/ do |name, filler|
    find_wish(name).filler.should == find_user(filler)
  end

  Then /^wish "(.*)" should have torrent set to "(.*)"$/ do |name, torrent_name|
    find_wish(name).torrent.should == find_torrent(torrent_name)

  end

  Then /^wish "(.*)" should be deleted$/ do |name|
    find_wish(name).should be_nil
  end

  Then /^filler for wish "(.*)" should be empty$/ do |name|
    find_wish(name).filler.should be_nil
  end

  Then /^torrent for wish "(.*)" should be empty$/ do |name|
    find_wish(name).torrent.should be_nil
  end

  Then /^a moderation report for wish "(.*)" with reason "(.*)" should be created$/ do |wish_name, reason|
    w = find_wish(wish_name)
    label = Report.make_target_label(w)
    r = Report.find_by_target_label_and_reason(label, reason)
    r.should_not be_nil
    r.target_path.should == wishes_path(:action => 'show', :id => w)
  end

  Then /^a comment by user "(.*)" with body equal to "(.*)" should be created for wish "(.*)"$/ do |username, body, wish_name|
    w = find_wish(wish_name)
    WishComment.find_by_user_id_and_body_and_wish_id(find_user(username), body, w).should_not be_nil
  end





