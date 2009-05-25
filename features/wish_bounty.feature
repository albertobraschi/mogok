
Feature: Wish Bounty
  In order to reward wish fillers
  As a registered user
  I want to be able to add bounties to wishes

  Background:
    Given I am logged in as "joe-the-user" with role "user"

  Scenario: A user adds a bounty to a wish
    Given user "joe-the-user" has 10485760 as uploaded
    And I have a wish with name "Joe The Users Wish" and owned by user "joe-the-user"
    When I go to the wish details page for wish "Joe The Users Wish"
    And I follow "bounties"
    And I follow "[ add bounty ]"
    And I fill in "bounty_amount" with "10"
    And I select "MB" from "bounty_unit"
    And I press "Confirm"
    Then I should see "Request bounty successfully added."
    And I should see "10.00 MB"
    And a wish_bounty with amount 10485760 should be created for wish "Joe The Users Wish"
    And wish "Joe The Users Wish" should have total bounty equal to 10485760
    And user "joe-the-user" should have uploaded equal to 0

  Scenario: A user tries to add a bounty to a wish having insufficient upload credit
    Given user "joe-the-user" has 0 as uploaded
    And I have a wish with name "Joe The Users Wish" and owned by user "joe-the-user"
    When I go to the wish details page for wish "Joe The Users Wish"
    And I follow "bounties"
    And I follow "[ add bounty ]"
    And I fill in "bounty_amount" with "10"
    And I select "MB" from "bounty_unit"
    And I press "Confirm"
    Then I should see "Your upload credit is insufficient."







