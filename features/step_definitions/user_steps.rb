
# GIVEN

Given /^I have a user with username (.*) and with role (.*)$/ do |username, role_name|
  role = fetch_role role_name
  fetch_user username, role
end

Given /^I have a role with name (.*)$/ do |name|
  fetch_role name
end

Given /^I have a style$/ do
  fetch_style
end

Given /^the user with username (.*) has the email (.*)$/ do |username, email|
  u = fetch_user username
  u.email = email
  u.save
end


# THEN

Then /^a user with username (.*) should be created$/ do |username|
  User.find_by_username(username).should_not == nil
end