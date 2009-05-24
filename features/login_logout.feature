
Feature: Login/Logout
  In order to use the system
  As a registered user
  I want to be able to log in and log out

  Scenario: Logging in
    Given I have a user with username JOE_THE_USER and with role USER
    When I go to the login page
    And I fill in username with JOE_THE_USER
    And I fill in password with JOE_THE_USER
    And I press Login
    Then I should see JOE_THE_USER
    And I should see Logout

  Scenario: Logging in with wrong password
    Given I have a user with username JOE_THE_USER and with role USER
    When I go to the login page
    And I fill in username with JOE_THE_USER
    And I fill in password with WRONG_PASS
    And I press Login
    Then I should see username
    And I should see password    

  Scenario: Logging out
    Given I am logged in as JOE_THE_USER with role USER
    When I follow the link Logout
    Then I should see username
    And I should see password
    When I go to the home page
    Then I should see username
    And I should see password