
Feature: Sign Up
  In order to use the system
  As an unregistered user
  I want to be able to sign up

  Scenario: Signup does not require invitation
    Given that signup is open
    And that signup does not require an invite code
    And I have a role with name USER
    And I have a style
    When I go to the signup page
    And I fill in user_username with JOE_THE_USER
    And I fill in user_password with MY_PASS
    And I fill in user_password_confirmation with MY_PASS
    And I fill in user_email with JOE@MAIL.COM
    And I press Sign Up
    Then a user with username JOE_THE_USER should be created
    And I should see JOE_THE_USER
    And I should see Logout

  Scenario: Signup by invitation only
    Given that signup is open
    And that signup requires an invite code
    And I have a user with username JOE_THE_INVITER and with role ADMIN
    And I have a role with name USER
    And I have a style
    And I have the invite code BEA53C766E9287EC created by user JOE_THE_INVITER with email JOE@MAIL.COM
    When I follow the invitation link for code BEA53C766E9287EC
    And I fill in user_username with JOE_THE_USER
    And I fill in user_password with MY_PASS
    And I fill in user_password_confirmation with MY_PASS
    And I press Sign Up
    Then a user with username JOE_THE_USER should be created
    And I should see JOE_THE_USER
    And I should see Logout
    And invitation with code BEA53C766E9287EC should be removed
    And user JOE_THE_INVITER should be the inviter of JOE_THE_USER

  Scenario: Signup with invite code when signup does not require it
    Given that signup is open
    And that signup does not require an invite code
    And I have a user with username JOE_THE_INVITER and with role ADMIN
    And I have a role with name USER
    And I have a style
    And I have the invite code BEA53C766E9287ED created by user JOE_THE_INVITER with email JOE@MAIL.COM
    When I follow the invitation link for code BEA53C766E9287ED
    And I fill in user_username with JOE_THE_USER
    And I fill in user_password with MY_PASS
    And I fill in user_password_confirmation with MY_PASS
    And I press Sign Up
    Then a user with username JOE_THE_USER should be created
    And I should see JOE_THE_USER
    And I should see Logout
    And invitation with code BEA53C766E9287ED should be removed
    And user JOE_THE_INVITER should be the inviter of JOE_THE_USER

