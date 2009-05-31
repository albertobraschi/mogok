
# GIVEN

Given /^that signup is open$/ do
  make_app_param 'signup_open', 'true'
end

Given /^that signup is closed$/ do
  make_app_param 'signup_open', 'false'
end

Given /^that signup requires an invite code$/ do
  make_app_param 'signup_by_invitation_only', 'true'
end

Given /^that signup does not require an invite code$/ do
  make_app_param 'signup_by_invitation_only', 'false'
end


# THEN

Then /^invitation with code "(.*)" should be removed$/ do |invite_code|
  Invitation.find_by_code(invite_code).should be_nil
end

Then /^user "(.*)" should be the inviter of "(.*)"$/ do |inviter, invitee|
  find_user(invitee).inviter.should == find_user(inviter)
end


