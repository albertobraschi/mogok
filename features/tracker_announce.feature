
Feature: Tracker Announce
  In order to download content
  As a registered user
  I want to be able to send announce requests to the tracker

  Background:
    Given I have a user with username "joe-the-announcer" and with role "user"
    And user "joe-the-announcer" has uploaded equal to 0
    And user "joe-the-announcer" has downloaded equal to 0
    And I have a user with username "joe-the-uploader" and with role "user"
    And I have a torrent with name "Joe The Uploaders Torrent" and owned by user "joe-the-uploader"

  Scenario: A user sends an announce request with event started
    Given I have one seeding peer for torrent "Joe The Uploaders Torrent" by user "joe-the-uploader" at IP "123.4.5.6" and port 33333
    And the counters for torrent "Joe The Uploaders Torrent" indicate 1 seeders and 0 leechers
    When user "joe-the-announcer" sends an announce with event "started" for torrent "Joe The Uploaders Torrent" using port 11111
    Then a new leeching peer for torrent "Joe The Uploaders Torrent" by user "joe-the-announcer" at IP "127.0.0.1" and port 11111 should be created
    And I should not see "Inexpected server error."
    And I should see "8:completei1e10:incompletei1e"
    And I should see "2:ip9:123.4.5.64:porti33333e"    
    And torrent "Joe The Uploaders Torrent" should have seeders equal to 1
    And torrent "Joe The Uploaders Torrent" should have leechers equal to 1

  Scenario: A user sends an announce request with event started and left equal to zero
    When user "joe-the-announcer" sends an announce with zero left and event started for torrent "Joe The Uploaders Torrent" using port 11111
    Then a new seeding peer for torrent "Joe The Uploaders Torrent" by user "joe-the-announcer" at IP "127.0.0.1" and port 11111 should be created
    And I should not see "Inexpected server error."
    And torrent "Joe The Uploaders Torrent" should have seeders equal to 1
    And torrent "Joe The Uploaders Torrent" should have leechers equal to 0

  Scenario: A user sends an announce request with no event and transferred data
    Given I have one leeching peer for torrent "Joe The Uploaders Torrent" by user "joe-the-announcer" at IP "127.0.0.1" and port 11111
    When user "joe-the-announcer" sends an announce with no event for torrent "Joe The Uploaders Torrent" with 12345 uploaded and 54321 downloaded using port 11111
    Then I should not see "Inexpected server error."
    And user "joe-the-announcer" should have uploaded equal to 12345
    And user "joe-the-announcer" should have downloaded equal to 54321

  Scenario: A user sends an announce request with event stopped
    Given I have one leeching peer for torrent "Joe The Uploaders Torrent" by user "joe-the-announcer" at IP "127.0.0.1" and port 11111
    And the counters for torrent "Joe The Uploaders Torrent" indicate 0 seeders and 1 leechers
    When user "joe-the-announcer" sends an announce with event "stopped" for torrent "Joe The Uploaders Torrent" using port 11111
    Then the peer for torrent "Joe The Uploaders Torrent" by user "joe-the-announcer" at IP "127.0.0.1" and port 11111 should be removed
    And I should not see "Inexpected server error."
    And torrent "Joe The Uploaders Torrent" should have seeders equal to 0
    And torrent "Joe The Uploaders Torrent" should have leechers equal to 0

  Scenario: A user sends an announce request with event completed
    Given I have one leeching peer for torrent "Joe The Uploaders Torrent" by user "joe-the-announcer" at IP "127.0.0.1" and port 11111
    And the counters for torrent "Joe The Uploaders Torrent" indicate 0 seeders and 1 leechers
    When user "joe-the-announcer" sends an announce with event "completed" for torrent "Joe The Uploaders Torrent" using port 11111
    Then the peer for torrent "Joe The Uploaders Torrent" and user "joe-the-announcer" at IP "127.0.0.1" and port 11111 should be set to seeder
    And I should not see "Inexpected server error."
    And a snatch for torrent "Joe The Uploaders Torrent" and user "joe-the-announcer" should be created
    And torrent "Joe The Uploaders Torrent" should have seeders equal to 1
    And torrent "Joe The Uploaders Torrent" should have leechers equal to 0















