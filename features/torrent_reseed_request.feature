
Feature: Torrent Reseed Request
  In order to have seeds in a dead torrent
  As a registered user
  I want to be able to request a reseed

  Background:
    Given I am logged in as "joe-the-user" with role "user"
    And the reseed request cost is 1 MB

  Scenario: A user request a reseed
    Given I have a user with username "joe-the-uploader" and with role "user"
    And I have a user with username "joe-the-samaritan" and with role "user"
    And I have a torrent with name "Joe The Uploaders Torrent" and created by user "joe-the-uploader"
    And user "joe-the-user" has uploaded equal to 1048576
    And the counters for torrent "Joe The Uploaders Torrent" indicate 0 seeders and 0 leechers
    And torrent "Joe The Uploaders Torrent" has snatches_count equal to 1
    And torrent "Joe The Uploaders Torrent" was snatched by user "joe-the-samaritan"
    When I go to the torrent details page for torrent "Joe The Uploaders Torrent"
    And I follow "reseed request"
    And I press "Confirm"
    Then I should see "Torrent Details"
    And I should see "Reseed requests successfully sent."
    And a system message with subject "reseed requested" should be received by "joe-the-samaritan"
    And user "joe-the-user" should have uploaded equal to 0
