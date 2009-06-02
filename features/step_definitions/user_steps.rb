
# given

  Given /^I have a user with username "(.*)" and with role "(.*)"$/ do |username, role_name|
    make_user username, fetch_role(role_name)
  end

  Given /^I have the system user$/ do
    make_system_user
  end

  Given /^user "(.*)" has email equal to "(.*)"$/ do |username, email|
    u = find_user username
    u.email = email
    u.save
  end

  Given /^user "(.*)" has uploaded equal to (\d+)$/ do |username, uploaded|
    u = find_user username
    u.uploaded = uploaded
    u.save
  end

  Given /^user "(.*)" has downloaded equal to (\d+)$/ do |username, downloaded|
    u = find_user username
    u.downloaded = downloaded
    u.save
  end

  Given /^user "(.*)" has a ticket with name "(.*)"$/ do |username, ticket|
    find_user(username).add_ticket! ticket
  end

# then

  Then /^a user with username "(.*)" should be created$/ do |username|
    find_user(username).should_not be_nil
  end

  Then /^user "(.*)" should have uploaded equal to (\d+)$/ do |username, uploaded|
    find_user(username).uploaded.should == uploaded.to_i
  end

  Then /^user "(.*)" should have downloaded equal to (\d+)$/ do |username, downloaded|
    find_user(username).downloaded.should == downloaded.to_i
  end

  Then /^user "(.*)" should have email equal to "(.*)"$/ do |username, email|
    find_user(username).email.should == email
  end

  Then /^a moderation report for user "(.*)" with reason "(.*)" should be created$/ do |username, reason|
    u = find_user username
    label = Report.make_target_label(u)
    r = Report.find_by_target_label_and_reason(label, reason)
    r.should_not be_nil
    r.target_path.should == users_path(:action => 'show', :id => u)
  end


