
# given

  Given /I am logged in as "(.*)" with role "(.*)"/ do |username, role|
    Given "I have a user with username \"#{username}\" and with role \"#{role}\""
    And "I am on the login page"
    When "I fill in \"username\" with \"#{username}\""
    And "I fill in \"password\" with \"#{username}\""
    And "I press \"Login\""
    Then "I should see \"#{username}\""
    And "I should see \"Logout\""
  end

# when

  When /^I fill file field "(.*)" with "(.*)"$/ do |field, file_name|
    # NOTE: test framework may corrupt binary files on Windows
    attach_file field, File.join(TEST_DATA_DIR, file_name)
  end



