
Feature: Password Recovery
  In order to use the system after forgetting my password
  As a registered user
  I want to be able to recover my password

  Background:
    Given I have a user with username "joe-the-user" and with role "user"

  Scenario: Requesting a recovery code    
    Given the user with username "joe-the-user" has the email "joe@mail.com"
    When I go to the password recovery page
    And I fill in "email" with "joe@mail.com"
    And I press "Confirm"
    Then I should see "A password recovery link has been sent to joe@mail.com."
    And I should see "username"
    And I should see "password"
    And a password recovery record for user "joe-the-user" should be created

  Scenario: Using the recovery code to change the password
    Given I have a password recovery with code "WRT5HJ7K8N287EC" requested by user "joe-the-user"
    And I have a login attempt for IP "127.0.0.1" with count equal to 1
    When I go to the change password page with recovery code "WRT5HJ7K8N287EC"
    And I fill in "password" with "my-new-pass"
    And I fill in "password_confirmation" with "my-new-pass"
    And I press "Confirm"
    And I fill in "username" with "joe-the-user"
    And I fill in "password" with "my-new-pass"
    And I press "Login"
    Then I should see "joe-the-user"
    And I should see "Logout"
    And a login attempt for IP "127.0.0.1" should not exist
