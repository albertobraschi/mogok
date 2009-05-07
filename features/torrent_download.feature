
Feature: Torrent download
  In order download content
  As a registered user
  I want to be able to download torrent files

  Scenario: Downloading a torrent file
    Given I am logged in as JOE_THE_USER with role USER
    And I have a torrent with name TEST_TORRENT and owned by user JOE_THE_USER
    When I go to the torrent details page for torrent TEST_TORRENT
    And I follow the link TEST_TORRENT.torrent
    Then the downloaded torrent and the test torrent info hashs should have equal

