
Feature: Torrent download
  In order to reward torrent creators
  As a registered user
  I want to be able to add rewards to torrents

  Background:
    Given I am logged in as "joe-the-user" with role "user"

  Scenario: Adding a reward to a torrent
    Given I have a user with username "joe-the-owner" and with role "user"
    And user "joe-the-user" has 10485760 as uploaded
    And user "joe-the-owner" has 0 as uploaded
    And I have a torrent with name "Joe The Owners Torrent" and owned by user "joe-the-owner"
    When I go to the torrent details page for torrent "Joe The Owners Torrent"
    And I follow "rewards"
    And I follow "[ add reward ]"
    And I fill in "reward_amount" with "10"
    And I select "MB" from "reward_unit"
    And I press "Confirm"
    Then I should see "Reward successfully added."
    And I should see "10.00 MB"
    And user "joe-the-owner" should have uploaded equal to 10485760
    And user "joe-the-user" should have uploaded equal to 0
    And torrent "Joe The Owners Torrent" should have total reward equal to 10485760

  Scenario: Adding a reward to a torrent having insufficient upload credit
    Given I have a user with username "joe-the-owner" and with role "user"    
    And I have a torrent with name "Joe The Owners Torrent" and owned by user "joe-the-owner"
    And user "joe-the-user" has 0 as uploaded
    When I go to the torrent details page for torrent "Joe The Owners Torrent"
    And I follow "rewards"
    And I follow "[ add reward ]"
    And I fill in "reward_amount" with "10"
    And I select "MB" from "reward_unit"
    And I press "Confirm"
    Then I should see "Your upload credit is insufficient."