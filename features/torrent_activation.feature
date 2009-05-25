
Feature: Torrent Activation
  In order to activate inactive torrents
  As a moderator
  I want to be able to activate them

  Scenario: A moderator activates an inactive torrent
    Given I am logged in as "joe-the-mod" with role "mod"
    And I have a user with username "joe-the-owner" and with role "user"
    And I have a torrent with name "Joe The Owners Torrent" and owned by user "joe-the-owner"
    And torrent "Joe The Owners Torrent" is inactive
    When I go to the torrent details page for torrent "Joe The Owners Torrent"
    And I follow "activate"
    Then I should see "Torrent successfully activated."
    And I should see "remove"
    And torrent "Joe The Owners Torrent" should be active
    And a system message with subject "torrent activated" should be received by "joe-the-owner"
