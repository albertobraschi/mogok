
Feature: Torrent Activation
  In order to reactivate inactive torrents
  As a moderator
  I want to be able to do so

  Scenario: A moderator reactivates an inactive torrent
    Given I am logged in as "joe-the-mod" with role "mod"
    And I have a user with username "joe-the-uploader" and with role "user"
    And I have a torrent with name "Joe The Uploaders Torrent" and owned by user "joe-the-uploader"
    And torrent "Joe The Uploaders Torrent" is inactive
    When I go to the torrent details page for torrent "Joe The Uploaders Torrent"
    And I follow "activate"
    Then I should see "Torrent successfully activated."
    And I should see "remove"
    And torrent "Joe The Uploaders Torrent" should be active
    And a system message with subject "torrent activated" should be received by "joe-the-uploader"
