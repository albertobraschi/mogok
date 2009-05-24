
# GIVEN

Given /^I have a login attempt for IP (.*) with count equal to (\d+)$/ do |ip, count|
  LoginAttempt.create :ip => ip, :attempts_count => count
end

Given /^I have a login attempt for IP (.*) with 1 remaining attempt$/ do |ip|
  LoginAttempt.create :ip => ip, :attempts_count => APP_CONFIG[:login][:max_attempts] - 1
end

Given /max login attempts is equal to (\d+)/ do |max_attempts|
  APP_CONFIG[:login][:max_attempts] = max_attempts.to_i
end

Given /the block time for exceeded login attempts is (\d+) hours/ do |hours|
  APP_CONFIG[:login][:block_hours] = hours.to_i
end


# THEN

Then /^a login attempt for IP (.*) should be created with count equal to (\d+)$/ do |ip, attempts_count|
  LoginAttempt.find_by_ip_and_attempts_count(ip, attempts_count).should_not == nil
end

Then /^the login attempt for IP (.*) should have count equal to (\d+)$/ do |ip, count|
  LoginAttempt.find_by_ip(ip).attempts_count.should == count.to_i
end

Then /^the login attempt for IP (.*) should be blocked$/ do |ip|
  LoginAttempt.find_by_ip(ip).blocked?.should == true
end

Then /^the login attempt for IP (.*) should not be blocked$/ do |ip|
  LoginAttempt.find_by_ip(ip).blocked?.should_not == true
end

Then /^a login attempt for IP (.*) should not exist$/ do |ip|
  LoginAttempt.find_by_ip(ip).should == nil
end

