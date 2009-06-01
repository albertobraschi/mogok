
# given

  Given /^I have a password recovery with code "(.*)" requested by user "(.*)"$/ do |code, username|
    make_password_recovery find_user(username), code
  end

# then

  Then /^a password recovery record for user "(.*)" should be created$/ do |username|
    PasswordRecovery.find_by_user_id(find_user(username)).should_not be_nil
  end

