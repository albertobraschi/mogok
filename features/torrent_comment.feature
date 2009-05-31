
Feature: Torrent comment
  In order to give my opinion about a torrent
  As a registered user
  I want to be able to add comments to it

  Background:
    Given I am logged in as "joe-the-user" with role "user"

  Scenario: A user adds a comment to a torrent
    Given I have a torrent with name "Joe The Users Torrent" and owned by user "joe-the-user"
    When I go to the torrent details page for torrent "Joe The Users Torrent"
    And I fill in "comment_body" with "Comment body."
    And I press "Submit"
    Then I should see "Torrent Details"
    And I should see "Comment successfully added."
    And a comment by user "joe-the-user" with body equal to "Comment body." should be created for torrent "Joe The Users Torrent"

  Scenario: A user edits its own torrent comment
    Given I have a user with username "joe-the-uploader" and with role "user"
    And I have a torrent with name "Joe The Uploaders Torrent" and owned by user "joe-the-uploader"
    And I have a comment by user "joe-the-user" for torrent "Joe The Uploaders Torrent" with body equal to "Comment body."
    When I go to the torrent details page for torrent "Joe The Uploaders Torrent"
    And I follow "edit"
    And I fill in "comment_body" with "Edited comment body."
    And I press "Edit"
    Then I should see "Torrent Details"
    And I should see "Comment successfully edited."
    And I should see "Edited comment body."
