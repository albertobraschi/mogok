
Feature: Torrent Upload
  In order to have my torrents in the system
  As a registered user
  I want to be able to upload them

  Background:
    Given I am logged in as "joe-the-user" with role "user"
    And I have a type with name "audio"
    And I have a category with name "music" and with type "audio"

  Scenario: Upload succeeds
    Given I have a format with name "ogg" and with type "audio"
    And I have a tag with name "blues" and with category "music"
    And I have a tag with name "pop" and with category "music"
    When I go to the torrent upload page
    And I select "music" from "torrent_category_id"
    And I fill file field "torrent_file" with "valid.torrent"
    And I fill in "torrent_name" with "Joe The Users Torrent"
    And I select "ogg" from "format_id"
    And I fill in "tags_str" with "blues, pop"
    And I press "Upload"
    Then I should see "Joe The Users Torrent"
    And I should see "music"
    And I should see "ogg"
    And I should see "blues"
    And I should see "pop"
    And I should see "54B1A5052B5B7D3BA4760F3BFC1135306A30FFD1"
    And the torrent "Joe The Users Torrent" should have 3 mapped files
    And the torrent "Joe The Users Torrent" should have 65536 as piece length
    And the torrent "Joe The Users Torrent" should have 2 tags

  Scenario: An invalid torrent file is uploaded
    When I go to the torrent upload page
    And I fill file field "torrent_file" with "invalid.torrent"
    And I select "music" from "torrent_category_id"
    And I fill in "torrent_name" with "Joe The Users Torrent"
    And I press "Upload"
    Then I should see "Invalid torrent file."

  Scenario: A file of another type is uploaded
    When I go to the torrent upload page
    And I fill file field "torrent_file" with "test.txt"
    And I select "music" from "torrent_category_id"
    And I fill in "torrent_name" with "Joe The Users Torrent"
    And I press "Upload"
    Then I should see "Must be a file of type torrent."






