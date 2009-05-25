
Feature: Logout
  In order to stop using the system
  As a registered user
  I want to be able to log out

  Background:
    Given I am logged in as "joe-the-user" with role "user"
    And I am on the homepage

  Scenario: Logging out
    When I follow "Logout"
    Then I should see "username"
    And I should see "password"
    And I should see "Please login"

  Scenario: Going to homepage after logging out
    When I follow "Logout"
    And I go to the homepage
    Then I should see "username"
    And I should see "password"
    And I should see "Please login"