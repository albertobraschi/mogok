
Feature: Tracker
  In order to download content
  As a registered user
  I want to be able to track the torrents

  Scenario: Announce[started]
    Given I have a user with username JOE_THE_ANNOUNCER and with role USER
    And I have a user with username JOE_THE_SEEDER and with role USER
    And I have a torrent with name JOE_THE_SEEDERS_TORRENT and owned by user JOE_THE_SEEDER
    And the torrent JOE_THE_SEEDERS_TORRENT has one seeding peer by user JOE_THE_SEEDER at ip 123.4.5.6 and port 33333
    When user JOE_THE_ANNOUNCER sends an announce with event started for torrent JOE_THE_SEEDERS_TORRENT
    Then the response should not contain Inexpected server error.
    And the response should contain 8:completei1e10:incompletei1e
    And the response should contain 2:ip9:123.4.5.64:porti33333e
    And a new peer should be added
    And the leechers counter for torrent JOE_THE_SEEDERS_TORRENT should be increased by one

  Scenario: Announce[no_event]
    Given I have a user with username JOE_THE_ANNOUNCER and with role USER
    And I have a user with username JOE_THE_OWNER and with role USER
    And I have a torrent with name JOE_THE_OWNERS_TORRENT and owned by user JOE_THE_OWNER
    And the torrent JOE_THE_OWNERS_TORRENT has one leeching peer by user JOE_THE_ANNOUNCER at ip 127.0.0.1 and port 33333
    When user JOE_THE_ANNOUNCER sends a no event announce for torrent JOE_THE_OWNERS_TORRENT with 12345 uploaded and 54321 downloaded
    Then the response should not contain Inexpected server error.
    And the uploaded and downloaded counters for user JOE_THE_ANNOUNCER should be increased in 12345 and 54321

  Scenario: Announce[stopped]
    Given I have a user with username JOE_THE_ANNOUNCER and with role USER
    And I have a user with username JOE_THE_OWNER and with role USER
    And I have a torrent with name JOE_THE_OWNERS_TORRENT and owned by user JOE_THE_OWNER
    And the counters for torrent JOE_THE_OWNERS_TORRENT indicate 0 seeders and 1 leechers
    And the torrent JOE_THE_OWNERS_TORRENT has one leeching peer by user JOE_THE_ANNOUNCER at ip 127.0.0.1 and port 33333
    When user JOE_THE_ANNOUNCER sends an announce with event stopped for torrent JOE_THE_OWNERS_TORRENT
    Then the response should not contain Inexpected server error.
    And one peer should be removed
    And the leechers counter for torrent JOE_THE_OWNERS_TORRENT should be decreased by one

  Scenario: Announce[completed]
    Given I have a user with username JOE_THE_ANNOUNCER and with role USER
    And I have a user with username JOE_THE_OWNER and with role USER
    And I have a torrent with name JOE_THE_OWNERS_TORRENT and owned by user JOE_THE_OWNER
    And the counters for torrent JOE_THE_OWNERS_TORRENT indicate 0 seeders and 1 leechers
    And the torrent JOE_THE_OWNERS_TORRENT has one leeching peer by user JOE_THE_ANNOUNCER at ip 127.0.0.1 and port 33333
    When user JOE_THE_ANNOUNCER sends an announce with event completed for torrent JOE_THE_OWNERS_TORRENT
    Then the response should not contain Inexpected server error.
    And the peer for torrent JOE_THE_OWNERS_TORRENT and user JOE_THE_ANNOUNCER should be set to seeder
    And a snatch for torrent JOE_THE_OWNERS_TORRENT and user JOE_THE_ANNOUNCER should be created
    And the leechers counter for torrent JOE_THE_OWNERS_TORRENT should be decreased by one
    And the seeders counter for torrent JOE_THE_OWNERS_TORRENT should be increased by one

  Scenario: Scrape
    Given I have a user with username JOE_THE_SCRAPER and with role USER
    And I have a user with username JOE_THE_OWNER and with role USER
    And I have a torrent with name JOE_THE_OWNERS_TORRENT and owned by user JOE_THE_OWNER
    And the counters for torrent JOE_THE_OWNERS_TORRENT indicate 7 seeders and 5 leechers
    And the torrent JOE_THE_OWNERS_TORRENT has been snatched 9 times
    When user JOE_THE_SCRAPER sends a scrape request for torrent JOE_THE_OWNERS_TORRENT
    Then the response should not contain Inexpected server error.
    And the response should contain 8:completei7e10:incompletei5e10:downloadedi9e

















