
Feature: Wish Report
  In order to report bad wishes
  As a registered user
  I want to be able to file moderation reports for them

  Background:
    Given I am logged in as "joe-the-user" with role "user"

  Scenario: A user reports a wish
    Given I have a user with username "joe-the-wisher" and with role "user"
    And I have a wish with name "Joe The Wishers Wish" and created by user "joe-the-wisher"
    When I go to the wish details page for wish "Joe The Wishers Wish"
    And I follow "report"
    And I fill in "reason" with "Whatever Reason"
    And I press "Send"
    Then I should see "Request Details"
    And I should see "Request successfully reported."
    And a moderation report for wish "Joe The Wishers Wish" with reason "Whatever Reason" should be created
