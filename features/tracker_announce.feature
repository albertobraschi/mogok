
Feature: Tracker Announce
  In order to download content
  As a registered user
  I want to be able to send announce requests to the tracker

  Background:
    Given I have a user with username "joe-the-announcer" and with role "user"

  Scenario: A user sends an announce request with event started
    Given I have a user with username "joe-the-seeder" and with role "user"
    And I have a torrent with name "Joe The Seeders Torrent" and owned by user "joe-the-seeder"
    And the torrent "Joe The Seeders Torrent" has one seeding peer by user "joe-the-seeder" at IP "123.4.5.6" and port 33333
    When user "joe-the-announcer" sends an announce with event "started" for torrent "Joe The Seeders Torrent"
    Then I should not see "Inexpected server error."
    And I should see "8:completei1e10:incompletei1e"
    And I should see "2:ip9:123.4.5.64:porti33333e"
    And a new peer should be created
    And the leechers counter for torrent "Joe The Seeders Torrent" should be increased by one

  Scenario: A user sends an announce request with no event
    Given I have a user with username "joe-the-owner" and with role "user"
    And I have a torrent with name "Joe The Owners Torrent" and owned by user "joe-the-owner"
    And the torrent "Joe The Owners Torrent" has one leeching peer by user "joe-the-announcer" at IP "127.0.0.1" and port 33333
    When user "joe-the-announcer" sends a no event announce for torrent "Joe The Owners Torrent" with 12345 uploaded and 54321 downloaded
    Then I should not see "Inexpected server error."
    And the uploaded and downloaded counters for user "joe-the-announcer" should be increased in 12345 and 54321

  Scenario: A user sends an announce request with event started
    Given I have a user with username "joe-the-owner" and with role "user"
    And I have a torrent with name "Joe The Owners Torrent" and owned by user "joe-the-owner"
    And the counters for torrent "Joe The Owners Torrent" indicate 0 seeders and 1 leechers
    And the torrent "Joe The Owners Torrent" has one leeching peer by user "joe-the-announcer" at IP "127.0.0.1" and port 33333
    When user "joe-the-announcer" sends an announce with event "stopped" for torrent "Joe The Owners Torrent"
    Then I should not see "Inexpected server error."
    And one peer should be deleted
    And the leechers counter for torrent "Joe The Owners Torrent" should be decreased by one

  Scenario: A user sends an announce request with event completed
    Given I have a user with username "joe-the-owner" and with role "user"
    And I have a torrent with name "Joe The Owners Torrent" and owned by user "joe-the-owner"
    And the counters for torrent "Joe The Owners Torrent" indicate 0 seeders and 1 leechers
    And the torrent "Joe The Owners Torrent" has one leeching peer by user "joe-the-announcer" at IP "127.0.0.1" and port 33333
    When user "joe-the-announcer" sends an announce with event "completed" for torrent "Joe The Owners Torrent"
    Then I should not see "Inexpected server error."
    And the peer for torrent "Joe The Owners Torrent" and user "joe-the-announcer" should be set to seeder
    And a snatch for torrent "Joe The Owners Torrent" and user "joe-the-announcer" should be created
    And the leechers counter for torrent "Joe The Owners Torrent" should be decreased by one
    And the seeders counter for torrent "Joe The Owners Torrent" should be increased by one
















