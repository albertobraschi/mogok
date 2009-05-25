
Feature: Tracker Scrape
  In order to have succinct information about the torrents health
  As a registered user
  I want to be able to scrape them

  Background:
    Given I have a user with username "joe-the-scraper" and with role "user"

  Scenario: Scrape
    Given I have a user with username "joe-the-owner" and with role "user"
    And I have a torrent with name "joe-the-owners-torrent" and owned by user "joe-the-owner"
    And the counters for torrent "joe-the-owners-torrent" indicate 7 seeders and 5 leechers
    And the torrent "joe-the-owners-torrent" has been snatched 9 times
    When user "joe-the-scraper" sends a scrape request for torrent "joe-the-owners-torrent"
    Then I should not see "Inexpected server error."
    And I should see "8:completei7e10:incompletei5e10:downloadedi9e"

















