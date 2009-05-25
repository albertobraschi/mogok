
Feature: Tracker Scrape
  In order to have succinct information about the torrents health
  As a registered user
  I want to be able to scrape them

  Background:
    Given I have a user with username "joe-the-scraper" and with role "user"

  Scenario: A users sends a scrape request
    Given I have a user with username "joe-the-owner" and with role "user"
    And I have a torrent with name "Joe The Owners Torrent" and owned by user "joe-the-owner"
    And the counters for torrent "Joe The Owners Torrent" indicate 7 seeders and 5 leechers
    And the torrent "Joe The Owners Torrent" has been snatched 9 times
    When user "joe-the-scraper" sends a scrape request for torrent "Joe The Owners Torrent"
    Then I should not see "Inexpected server error."
    And I should see "8:completei7e10:incompletei5e10:downloadedi9e"

















