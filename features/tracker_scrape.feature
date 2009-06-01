
Feature: Tracker Scrape
  In order to have succinct information about the torrents states
  As a registered user
  I want to be able to scrape them

  Background:
    Given I have a user with username "joe-the-scraper" and with role "user"

  Scenario: A users sends a scrape request
    Given I have a user with username "joe-the-uploader" and with role "user"
    And I have a torrent with name "Joe The Uploaders Torrent" and created by user "joe-the-uploader"
    And the counters for torrent "Joe The Uploaders Torrent" indicate 7 seeders and 5 leechers
    And torrent "Joe The Uploaders Torrent" has snatches_count equal to 9
    When user "joe-the-scraper" sends a scrape request for torrent "Joe The Uploaders Torrent"
    Then I should not see "Inexpected server error."
    And I should see "8:completei7e10:incompletei5e10:downloadedi9e"

















