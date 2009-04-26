
Feature: Password recovery
  In order to use the system
  As a registered user
  I want to be able to recover my password

  Scenario: Requesting a recovery code
    Given I have a user with username JOE_THE_USER and with role USER
    And the user with username JOE_THE_USER has the email JOE@MYRECOVERYTEST.ORG
    When I go to the password recovery page
    And I fill in email with JOE@MYRECOVERYTEST.ORG
    And I press Confirm
    Then I should see A password recovery link has been sent to JOE@MYRECOVERYTEST.ORG
    And I should see username
    And I should see password
    And a password recovery record for user JOE_THE_USER should be created

  Scenario: Using the recovery code to change the password
    Given I have a user with username JOE_THE_USER and with role USER
    And I have the recovery code WRT5HJ7K8N287EC requested by user JOE_THE_USER
    When I follow the password recovery link for code WRT5HJ7K8N287EC
    Then I should see JOE_THE_USER
    When I fill in password with MY_NEW_PASS
    And I fill in password_confirmation with MY_NEW_PASS
    And I press Confirm
    Then I should see Password successfully changed
    When I fill in username with JOE_THE_USER
    And I fill in password with MY_NEW_PASS
    And I press Login
    Then I should see JOE_THE_USER
    And I should see Logout
