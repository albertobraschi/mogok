
Feature: Torrent download
  In order to reward torrent creators
  As a registered user
  I want to be able to add rewards to torrents

  Background:
    Given I am logged in as "joe-the-user" with role "user"

  Scenario: A user adds a reward to a torrent
    Given I have a user with username "joe-the-uploader" and with role "user"
    And user "joe-the-user" has uploaded equal to 10485760
    And user "joe-the-uploader" has uploaded equal to 0
    And I have a torrent with name "Joe The Uploaders Torrent" and created by user "joe-the-uploader"
    When I go to the torrent details page for torrent "Joe The Uploaders Torrent"
    And I follow "rewards"
    And I follow "[ add reward ]"
    And I fill in "reward_amount" with "10"
    And I select "MB" from "reward_unit"
    And I press "Confirm"
    Then I should see "Reward successfully added."
    And I should see "10.00 MB"
    And user "joe-the-uploader" should have uploaded equal to 10485760
    And user "joe-the-user" should have uploaded equal to 0
    And torrent "Joe The Uploaders Torrent" should have total reward equal to 10485760

  Scenario: A user tries to add a reward to a torrent having insufficient upload credit
    Given I have a user with username "joe-the-uploader" and with role "user"
    And I have a torrent with name "Joe The Uploaders Torrent" and created by user "joe-the-uploader"
    And user "joe-the-user" has uploaded equal to 0
    When I go to the torrent details page for torrent "Joe The Uploaders Torrent"
    And I follow "rewards"
    And I follow "[ add reward ]"
    And I fill in "reward_amount" with "10"
    And I select "MB" from "reward_unit"
    And I press "Confirm"
    Then I should see "Your upload credit is insufficient."