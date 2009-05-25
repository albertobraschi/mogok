
Feature: Torrent download
  In order to download content
  As a registered user
  I want to be able to download torrent files

  Scenario: Downloading a torrent file
    Given I am logged in as "joe-the-user" with role "user"
    And I have a torrent with name "joe-the-users-torrent" and owned by user "joe-the-user"
    When I go to the torrent details page for torrent "joe-the-users-torrent"
    And I follow "joe-the-users-torrent.torrent"
    Then the downloaded torrent file should have same info hash as torrent "joe-the-users-torrent"

