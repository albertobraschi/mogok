
# GIVEN

Given /^I have the recovery code (.*) requested by user (.*)$/ do |recovery_code, username|
  user = fetch_user username
  PasswordRecovery.create :user_id => user.id, :code => recovery_code, :created_at => Time.now
end

# WHEN

When /^I go to the password recovery page$/ do
  visit 'password_recovery'
end

When /^I follow the password recovery link for code (.*)$/ do |recovery_code|
  get change_password_url(:recovery_code => recovery_code)
end


# THEN

Then /^a password recovery record for user (.*) should be created$/ do |username|
  user = fetch_user username
  PasswordRecovery.find_by_user_id(user.id).should_not == nil
end

