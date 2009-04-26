
# GIVEN

Given /I am logged in as (.*) with role (.*)/ do |username, role|
  Given "I have a user with username #{username} and with role #{role}"
  Given "I log in as #{username}"
end

Given /^I log in as (.*)$/ do |username|
  u = fetch_user username
  visit 'login'
  fill_in :username, :with => u.username
  fill_in :password, :with => u.username
  click_button 'Login'
  response.body.should =~ /#{'Logout'}/m
end


# WHEN

When /^I go to the login page$/ do
  visit 'login'
end


