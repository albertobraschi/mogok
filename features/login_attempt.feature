
Feature: Login Attempt
  In order to protect the system against brute force login
  As a system developer
  I want to be able to block an IP after the login attempts limit is exceeded

  Scenario: Login attempt is created
    Given I have a user with username JOE_THE_USER and with role USER
    When I go to the login page
    And I fill in username with JOE_THE_USER
    And I fill in password with WRONG_PASS
    And I press Login
    Then a login attempt for IP 127.0.0.1 should be created with count equal to 1

  Scenario: Login attempt is incremented
    Given I have a user with username JOE_THE_USER and with role USER
    And max login attempts is equal to 5
    And I have a login attempt for IP 127.0.0.1 with count equal to 1
    When I go to the login page
    And I fill in username with JOE_THE_USER
    And I fill in password with WRONG_PASS
    And I press Login
    Then I should see username
    And I should see password
    And I should see Invalid login data. Remaining attempts: 3
    And the login attempt for IP 127.0.0.1 should have count equal to 2
    And the login attempt for IP 127.0.0.1 should not be blocked

  Scenario: Login attempts limit exceeded
    Given I have a user with username JOE_THE_USER and with role USER
    And the block time for exceeded login attempts is 4 hours
    And I have a login attempt for IP 127.0.0.1 with 1 remaining attempt
    When I go to the login page
    And I fill in username with JOE_THE_USER
    And I fill in password with WRONG_PASS
    And I press Login
    Then I should see username
    And I should see password
    And I should see Login will remain blocked for 4 hours. Try to recover your password.
    And the login attempt for IP 127.0.0.1 should have count equal to 0
    And the login attempt for IP 127.0.0.1 should be blocked

  Scenario: Login attempt is deleted
    Given I have a user with username JOE_THE_USER and with role USER
    And I have a login attempt for IP 127.0.0.1 with count equal to 1
    When I go to the login page
    And I fill in username with JOE_THE_USER
    And I fill in password with JOE_THE_USER
    And I press Login
    Then I should see JOE_THE_USER
    And I should see Logout
    And a login attempt for IP 127.0.0.1 should not exist

