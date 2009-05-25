
Feature: Torrent Report
  In order to report bad torrents
  As a registered user
  I want to be able to file moderation reports for them

  Background:
    Given I am logged in as "joe-the-user" with role "user"

  Scenario: A user reports a torrent
    Given I have a user with username "joe-the-owner" and with role "user"
    And I have a torrent with name "Joe The Owners Torrent" and owned by user "joe-the-owner"
    When I go to the torrent details page for torrent "Joe The Owners Torrent"
    And I follow "report"
    And I fill in "reason" with "Whatever Reason"
    And I press "Send"
    Then I should see "Torrent Details"
    And I should see "Torrent successfully reported."
    And a moderation report for torrent "Joe The Owners Torrent" with reason "Whatever Reason" should be created
