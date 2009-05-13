
# GIVEN

Given /^that signup is open$/ do
  AppParam.create :name => 'signup_open', :value => 'true'
end

Given /^that signup requires an invite code$/ do
  AppParam.create :name => 'signup_by_invitation_only', :value => 'true'
end

Given /^that signup does not require an invite code$/ do
  AppParam.create :name => 'signup_by_invitation_only', :value => 'false'
end

Given /^I have the invite code (.*) created by user (.*) with email (.*)$/ do |invite_code, username, email|
  inviter = fetch_user username
  Invitation.create invite_code, inviter, email
end


# WHEN

When /^I go to the signup page$/ do
  visit 'signup'
end

When /^I follow the invitation link for code (.*)$/ do |invite_code|
  get signup_with_invite_url(:invite_code => invite_code)
end

# THEN

Then /^invitation with code (.*) should be removed$/ do |invite_code|
  invitation = Invitation.find_by_code invite_code
  invitation.should == nil
end

Then /^user (.*) should be the inviter of (.*)$/ do |inviter_username, username|
  inviter = fetch_user inviter_username
  u = fetch_user username
  inviter.id.should == u.inviter.id
end


