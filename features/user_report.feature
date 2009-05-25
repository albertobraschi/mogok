
Feature: User Report
  In order to keep report bad users
  As a registered user
  I want to be able to file moderation reports for them

  Background:
    Given I am logged in as "joe-the-user" with role "user"

  Scenario: A user reports a wish
    Given I have a user with username "joe-the-badboy" and with role "user"
    When I go to the user details page for user "joe-the-badboy"
    And I follow "report"
    And I fill in "reason" with "Whatever Reason"
    And I press "Send"
    Then I should see "User Details"
    And I should see "User successfully reported."
    And a moderation report for user "joe-the-badboy" with reason "Whatever Reason" should be created
