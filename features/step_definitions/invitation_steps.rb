
# GIVEN

Given /^I have an invitation with email "(.*)" and created by "(.*)"$/ do |email, username|
  Factory(:invitation, :user => fetch_user(username), :email => email)
end

Given /^I have an invitation with code "(.*)" and email "(.*)" created by user "(.*)"$/ do |code, email, username|
  Factory(:invitation, :code => code, :user => fetch_user(username), :email => email)
end


# THEN

Then /^an invitation record with email "(.*)" and owned by "(.*)" should be created$/ do |email, username|
  Invitation.find_by_email_and_user_id(email, fetch_user(username)).should_not be_nil
end

Then /^I should see the code for invitation with email "(.*)" and owned by "(.*)"$/ do |email, username|  
  i = Invitation.find_by_email_and_user_id(email, fetch_user(username))
  response.should contain(i.code)
end

