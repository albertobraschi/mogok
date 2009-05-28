
Feature: Login
  In order to use the system
  As a registered user
  I want to be able to log in

  Background:
    Given I have a user with username "joe-the-user" and with role "user"
    And I am on the login page

  Scenario: Logging in
    When I fill in "username" with "joe-the-user"
    And I fill in "password" with "joe-the-user"
    And I press "Login"
    Then I should see "joe-the-user"
    And I should see "Logout"

  Scenario: Logging in with wrong password
    When I fill in "username" with "joe-the-user"
    And I fill in "password" with "nononono"
    And I press "Login"
    Then I should see "username"
    And I should see "password"
    And I should see "Invalid login data."
