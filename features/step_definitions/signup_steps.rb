
# GIVEN

Given /^that signup is open$/ do
  AppParam.create :name => 'signup_open', :value => 'true'
end

Given /^that signup is closed$/ do
  AppParam.create :name => 'signup_open', :value => 'false'
end

Given /^that signup requires an invite code$/ do
  AppParam.create :name => 'signup_by_invitation_only', :value => 'true'
end

Given /^that signup does not require an invite code$/ do
  AppParam.create :name => 'signup_by_invitation_only', :value => 'false'
end

Given /^I have an invitation with code "(.*)" and email "(.*)" created by user "(.*)"$/ do |code, email, username|
  inviter = fetch_user username
  Invitation.create code, inviter, email
end


# THEN

Then /^invitation with code "(.*)" should be removed$/ do |invite_code|
  Invitation.find_by_code(invite_code).should be_nil
end

Then /^user "(.*)" should be the inviter of "(.*)"$/ do |inviter, invitee|
  fetch_user(invitee).inviter.should == fetch_user(inviter)
end


