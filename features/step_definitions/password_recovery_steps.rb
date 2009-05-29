
# GIVEN

Given /^I have a password recovery with code "(.*)" requested by user "(.*)"$/ do |code, username|
  Factory(:password_recovery, :user => fetch_user(username), :code => code)
end


# THEN

Then /^a password recovery record for user "(.*)" should be created$/ do |username|
  PasswordRecovery.find_by_user_id(fetch_user(username)).should_not be_nil
end

