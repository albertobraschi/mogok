
# GIVEN

Given /^I have no login attempts for IP "(.*)"$/ do |ip|
  LoginAttempt.find_by_ip(ip).should be_nil
end

Given /^I have a login attempt for IP "(.*)" with count equal to (\d+)$/ do |ip, count|
  Factory(:login_attempt, :ip => ip, :attempts_count => count)
end

Given /^I have a login attempt for IP "(.*)" with one remaining attempt$/ do |ip|
  Factory(:login_attempt, :ip => ip, :attempts_count => APP_CONFIG[:login][:max_attempts] - 1)
end

Given /max login attempts is equal to (\d+)/ do |max_attempts|
  APP_CONFIG[:login][:max_attempts] = max_attempts.to_i
end

Given /the block time for exceeded login attempts is (\d+) hours/ do |hours|
  APP_CONFIG[:login][:block_hours] = hours.to_i
end


# THEN

Then /^the login attempt for IP "(.*)" should have count equal to (\d+)$/ do |ip, count|
  LoginAttempt.find_by_ip(ip).attempts_count.should == count.to_i
end

Then /^the login attempt for IP "(.*)" should be blocked$/ do |ip|
  LoginAttempt.find_by_ip(ip).blocked?.should be_true
end

Then /^the login attempt for IP "(.*)" should not be blocked$/ do |ip|
  LoginAttempt.find_by_ip(ip).blocked?.should be_false
end

Then /^a login attempt for IP "(.*)" should not exist$/ do |ip|
  LoginAttempt.find_by_ip(ip).should be_nil
end



