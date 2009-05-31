
# GIVEN

Given /^I have an invitation with email "(.*)" and created by "(.*)"$/ do |email, username|
  make_invitation find_user(username), email
end

Given /^I have an invitation with code "(.*)" and email "(.*)" created by user "(.*)"$/ do |code, email, username|
  make_invitation find_user(username), email, code
end


# THEN

Then /^an invitation record with email "(.*)" and owned by "(.*)" should be created$/ do |email, username|
  Invitation.find_by_email_and_user_id(email, find_user(username)).should_not be_nil
end

Then /^I should see the code for invitation with email "(.*)" and owned by "(.*)"$/ do |email, username|  
  i = Invitation.find_by_email_and_user_id(email, find_user(username))
  response.should contain(i.code)
end

