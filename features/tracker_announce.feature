
Feature: Tracker Announce
  In order to download content
  As a registered user
  I want to be able to send announce requests to the tracker

  Background:
    Given I have a user with username "joe-the-announcer" and with role "user"

  Scenario: Announce[started]
    Given I have a user with username "joe-the-seeder" and with role "user"
    And I have a torrent with name "joe-the-seeders-torrent" and owned by user "joe-the-seeder"
    And the torrent "joe-the-seeders-torrent" has one seeding peer by user "joe-the-seeder" at IP "123.4.5.6" and port 33333
    When user "joe-the-announcer" sends an announce with event "started" for torrent "joe-the-seeders-torrent"
    Then I should not see "Inexpected server error."
    And I should see "8:completei1e10:incompletei1e"
    And I should see "2:ip9:123.4.5.64:porti33333e"
    And a new peer should be created
    And the leechers counter for torrent "joe-the-seeders-torrent" should be increased by one

  Scenario: Announce[no_event]
    Given I have a user with username "joe-the-owner" and with role "user"
    And I have a torrent with name "joe-the-owners-torrent" and owned by user "joe-the-owner"
    And the torrent "joe-the-owners-torrent" has one leeching peer by user "joe-the-announcer" at IP "127.0.0.1" and port 33333
    When user "joe-the-announcer" sends a no event announce for torrent "joe-the-owners-torrent" with 12345 uploaded and 54321 downloaded
    Then I should not see "Inexpected server error."
    And the uploaded and downloaded counters for user "joe-the-announcer" should be increased in 12345 and 54321

  Scenario: Announce[stopped]
    Given I have a user with username "joe-the-owner" and with role "user"
    And I have a torrent with name "joe-the-owners-torrent" and owned by user "joe-the-owner"
    And the counters for torrent "joe-the-owners-torrent" indicate 0 seeders and 1 leechers
    And the torrent "joe-the-owners-torrent" has one leeching peer by user "joe-the-announcer" at IP "127.0.0.1" and port 33333
    When user "joe-the-announcer" sends an announce with event "stopped" for torrent "joe-the-owners-torrent"
    Then I should not see "Inexpected server error."
    And one peer should be deleted
    And the leechers counter for torrent "joe-the-owners-torrent" should be decreased by one

  Scenario: Announce[completed]
    Given I have a user with username "joe-the-owner" and with role "user"
    And I have a torrent with name "joe-the-owners-torrent" and owned by user "joe-the-owner"
    And the counters for torrent "joe-the-owners-torrent" indicate 0 seeders and 1 leechers
    And the torrent "joe-the-owners-torrent" has one leeching peer by user "joe-the-announcer" at IP "127.0.0.1" and port 33333
    When user "joe-the-announcer" sends an announce with event "completed" for torrent "joe-the-owners-torrent"
    Then I should not see "Inexpected server error."
    And the peer for torrent "joe-the-owners-torrent" and user "joe-the-announcer" should be set to seeder
    And a snatch for torrent "joe-the-owners-torrent" and user "joe-the-announcer" should be created
    And the leechers counter for torrent "joe-the-owners-torrent" should be decreased by one
    And the seeders counter for torrent "joe-the-owners-torrent" should be increased by one
















