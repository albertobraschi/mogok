
Feature: Torrent Removal
  In order to inactivate torrents
  As a registered user or a moderator
  I want to be able to inactivate them

  Scenario: A user inactivates its own torrent
    Given I am logged in as "joe-the-user" with role "user"
    And I have a torrent with name "Joe The Users Torrent" and owned by user "joe-the-user"
    When I go to the torrent details page for torrent "Joe The Users Torrent"
    And I follow "remove"
    And I fill in "reason" with "Whatever Reason"
    And I press "Remove"
    Then I should see "Your torrent will stay inactive until a moderator removes it."
    And torrent "Joe The Users Torrent" should be inactive
    And a moderation report for torrent "Joe The Users Torrent" with reason "inactivated" should be created

  Scenario: A moderator inactivates another users torrent
    Given I am logged in as "joe-the-mod" with role "mod"
    And I have a user with username "joe-the-owner" and with role "user"
    And I have a torrent with name "Joe The Owners Torrent" and owned by user "joe-the-owner"
    When I go to the torrent details page for torrent "Joe The Owners Torrent"
    And I follow "remove"
    And I fill in "reason" with "Whatever Reason"
    And I press "Remove"
    Then I should see "Torrent successfully inactivated."
    And I should see "activate"
    And torrent "Joe The Owners Torrent" should be inactive
    And a system message with subject "torrent inactivated" should be received by "joe-the-owner"