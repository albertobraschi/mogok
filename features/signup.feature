
Feature: Sign Up
  In order to use the system
  As an unregistered user
  I want to be able to sign up

  Scenario: Signup does not require invitation
    Given that signup is open
    And that signup does not require an invite code
    And I have a role with name "user"
    And I have a style with name "default"
    When I go to the signup page without invite code
    And I fill in "user_username" with "joe-the-user"
    And I fill in "user_password" with "my-pass"
    And I fill in "user_password_confirmation" with "my-pass"
    And I fill in "user_email" with "joe@mail.com"
    And I press "Sign Up"
    Then a user with username "joe-the-user" should be created
    And I should see "joe-the-user"
    And I should see "Logout"

  Scenario: Signup by invitation only
    Given that signup is open
    And that signup requires an invite code
    And I have a user with username "joe-the-inviter" and with role "admin"
    And I have a role with name "user"
    And I have a style with name "default"
    And I have an invitation with code "BEA53C766E9287EC" and email "joe-the-user@mail.com" created by user "joe-the-inviter"
    When I go to the signup page with invite code "BEA53C766E9287EC"
    And I fill in "user_username" with "joe-the-user"
    And I fill in "user_password" with "my-pass"
    And I fill in "user_password_confirmation" with "my-pass"
    And I press "Sign Up"
    Then I should see "joe-the-user"
    And I should see "Logout"
    And invitation with code "BEA53C766E9287EC" should be removed
    And a user with username "joe-the-user" should be created
    And user with username "joe-the-user" should have email equal to "joe-the-user@mail.com"
    And user "joe-the-inviter" should be the inviter of "joe-the-user"

  Scenario: Signup with invite code when signup does not require it
    Given that signup is open
    And that signup does not require an invite code
    And I have a user with username "joe-the-inviter" and with role "admin"
    And I have a role with name "user"
    And I have a style with name "default"
    And I have an invitation with code "CID53C766E9287ED" and email "joe-the-user@mail.com" created by user "joe-the-inviter"
    When I go to the signup page with invite code "CID53C766E9287ED"
    And I fill in "user_username" with "joe-the-user"
    And I fill in "user_password" with "my-pass"
    And I fill in "user_password_confirmation" with "my-pass"
    And I press "Sign Up"
    Then I should see "joe-the-user"
    And I should see "Logout"
    And invitation with code "CID53C766E9287ED" should be removed
    And a user with username "joe-the-user" should be created
    And user with username "joe-the-user" should have email equal to "joe-the-user@mail.com"
    And user "joe-the-inviter" should be the inviter of "joe-the-user"

