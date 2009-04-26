
# GIVEN
Given /^I go to the home page$/ do
  visit root_path
end


# WHEN

When /^I fill in (.*) with (.*)$/ do |field, value|
  fill_in field, :with => value
end

When /^I follow the link (.*)$/ do |link|
  click_link link
end

When /^I specify file field (.*) as (.*)$/ do |field, file_name|
  # NOTE: the test framework corrupts binary files on windows
  attach_file field, File.join(TEST_DATA_DIR, file_name)
end

When /^I select (.*) from (.*)$/ do |value, field|
  select value, :from => field
end

When /^I press (.*)$/ do |button|
  click_button button
end


# THEN

Then /^I should see (.*)$/ do |text|
  response.body.should =~ /#{text}/m
end

Then /^I should not see (.*)$/ do |text|
  response.body.should_not =~ /#{text}/m
end

Then /^the response should contain (.*)$/ do |text|
  response.body.should =~ /#{text}/m
end

Then /^the response should not contain (.*)$/ do |text|
  response.body.should_not =~ /#{text}/m
end
