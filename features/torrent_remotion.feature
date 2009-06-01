
Feature: Torrent Remotion
  In order to remove torrents from the site
  As a moderator
  I want to be able to completely remove them

  Scenario: A moderator completely removes another users inactive torrent
    Given I am logged in as "joe-the-mod" with role "mod"
    And I have a user with username "joe-the-uploader" and with role "user"
    And I have a torrent with name "Joe The Uploaders Torrent" and created by user "joe-the-uploader"
    And torrent "Joe The Uploaders Torrent" is inactive
    When I go to the torrent details page for torrent "Joe The Uploaders Torrent"
    And I follow "remove"
    And I fill in "reason" with "Whatever Reason"
    And I press "Remove"
    Then I should see "Torrent successfully deleted from system."
    And torrent "Joe The Uploaders Torrent" should be deleted
    And a system message with subject "torrent removed" should be received by "joe-the-uploader"

  Scenario: A moderator completely removes another users active torrent
    Given I am logged in as "joe-the-mod" with role "mod"
    And I have a user with username "joe-the-uploader" and with role "user"
    And I have a torrent with name "Joe The Uploaders Torrent" and created by user "joe-the-uploader"
    When I go to the torrent details page for torrent "Joe The Uploaders Torrent"
    And I follow "remove"
    And I fill in "reason" with "Whatever Reason"
    And I check "destroy"
    And I press "Remove"
    Then I should see "Torrent successfully deleted from system."
    And torrent "Joe The Uploaders Torrent" should be deleted
    And a system message with subject "torrent removed" should be received by "joe-the-uploader"


