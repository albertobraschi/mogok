
Feature: Torrent Download
  In order to download content
  As a registered user
  I want to be able to download torrent files

  Background:
    Given I am logged in as "joe-the-user" with role "user"
    And I uploaded a torrent with name "Joe The Users Torrent"

  Scenario: A user downloads a torrent file    
    When I go to the torrent details page for torrent "Joe The Users Torrent"
    And I follow "Joe The Users Torrent.torrent"
    Then the downloaded torrent file should have same info hash as torrent "Joe The Users Torrent"

