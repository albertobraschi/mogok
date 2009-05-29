
# GIVEN

Given /^that signup is open$/ do
  Factory(:app_param, :name => 'signup_open', :value => 'true')
end

Given /^that signup is closed$/ do
  Factory(:app_param, :name => 'signup_open', :value => 'false')
end

Given /^that signup requires an invite code$/ do
  Factory(:app_param, :name => 'signup_by_invitation_only', :value => 'true')
end

Given /^that signup does not require an invite code$/ do
  Factory(:app_param, :name => 'signup_by_invitation_only', :value => 'false')
end


# THEN

Then /^invitation with code "(.*)" should be removed$/ do |invite_code|
  Invitation.find_by_code(invite_code).should be_nil
end

Then /^user "(.*)" should be the inviter of "(.*)"$/ do |inviter, invitee|
  fetch_user(invitee).inviter.should == fetch_user(inviter)
end


