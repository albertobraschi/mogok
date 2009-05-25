
# GIVEN

Given /^I have an invitation with email "(.*)" and created by "(.*)"$/ do |email, username|
  inviter = fetch_user username
  Invitation.create('WHATEVER_CODE', inviter, email)
end

# THEN

Then /^an invitation record with email "(.*)" and owned by "(.*)" should be created$/ do |email, username|
  user = fetch_user username
  Invitation.find_by_email_and_user_id(email, user).should_not be_nil
end

Then /^I should see the code for invitation with email "(.*)" and owned by "(.*)"$/ do |email, username|
  user = fetch_user username
  i = Invitation.find_by_email_and_user_id(email, user)
  response.should contain(i.code)
end

