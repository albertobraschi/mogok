
# GIVEN

Given /^I have a user with username "(.*)" and with role "(.*)"$/ do |username, role_name|
  role = fetch_role role_name
  fetch_user username, role
end

Given /^I have the system user$/ do
  fetch_system_user
end

Given /^the user with username "(.*)" has the email "(.*)"$/ do |username, email|
  u = fetch_user username
  u.email = email
  u.save
end

Given /^user with username "(.*)" has (\d+) as uploaded$/ do |username, uploaded|
  u = fetch_user username
  u.uploaded = uploaded
  u.save
end

Given /^user with username "(.*)" has a ticket with name "(.*)"$/ do |username, ticket|
  u = fetch_user username
  if u.tickets
    u.tickets += " #{ticket}"
  else
    u.tickets = ticket
  end
  u.save
end


# THEN

Then /^a user with username "(.*)" should be created$/ do |username|
  User.find_by_username(username).should_not be_nil
end

Then /^user with username "(.*)" should have uploaded equal to (\d+)$/ do |username, uploaded|
  u = fetch_user username
  u.uploaded.should == uploaded.to_i
end

Then /^user with username "(.*)" should have email equal to "(.*)"$/ do |username, email|
  u = fetch_user username
  u.email.should == email
end


