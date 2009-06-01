
Feature: Wish Filling
  In order to make wishers happy and eventually be rewarded
  As a registered user
  I want to be able to fill wishes

  Background:
    Given I am logged in as "joe-the-user" with role "user"

  Scenario: A user fills a wish
    Given I have a user with username "joe-the-wisher" and with role "user"
    And I have a wish with name "Joe The Wishers Wish" and created by user "joe-the-wisher"
    And I have a torrent with name "Joe The Users Torrent" and created by user "joe-the-user"
    When I go to the wish details page for wish "Joe The Wishers Wish"
    And I follow "fill this request"
    And I fill info_hash field with info hash hex for torrent "Joe The Users Torrent"
    And I press "Confirm"
    Then I should see "Request successfully filled."
    And wish "Joe The Wishers Wish" should be set to pending
    And wish "Joe The Wishers Wish" should have filler set to "joe-the-user"
    And wish "Joe The Wishers Wish" should have torrent set to "Joe The Users Torrent"
    And a moderation report for wish "Joe The Wishers Wish" with reason "pending" should be created

  Scenario: A user tries to fill its own wish
    Given I have a wish with name "Joe The Users Wish" and created by user "joe-the-user"
    When I go to the wish filling page for wish "Joe The Users Wish"
    Then I should see "Access Denied"

  Scenario: A user tries to fill a wish with an invalid torrent info hash
    Given I have a user with username "joe-the-wisher" and with role "user"
    And I have a wish with name "Joe The Wishers Wish" and created by user "joe-the-wisher"
    When I go to the wish details page for wish "Joe The Wishers Wish"
    And I follow "fill this request"
    And I fill in "info_hash" with "nonononononono"
    And I press "Confirm"
    Then I should see "Invalid torrent info hash."

  Scenario: A user tries to fill a wish with another users torrent
    Given I have a user with username "joe-the-wisher" and with role "user"
    And I have a user with username "joe-the-uploader" and with role "user"
    And I have a wish with name "Joe The Wishers Wish" and created by user "joe-the-wisher"
    And I have a torrent with name "Joe The Uploaders Torrent" and created by user "joe-the-uploader"
    When I go to the wish details page for wish "Joe The Wishers Wish"
    And I follow "fill this request"
    And I fill info_hash field with info hash hex for torrent "Joe The Uploaders Torrent"
    And I press "Confirm"
    Then I should see "Only the torrent uploader can use it to fill a request."

  Scenario: A user tries to fill two wishes with the same torrent
    Given I have a user with username "joe-the-wisher" and with role "user"
    And I have a wish with name "Joe The Wishers Wish" and created by user "joe-the-wisher"
    And I have a wish with name "Another Joe The Wishers Wish" and created by user "joe-the-wisher"
    And I have a torrent with name "Joe The Users Torrent" and created by user "joe-the-user"
    And wish "Joe The Wishers Wish" was filled and approved with torrent "Joe The Users Torrent"    
    When I go to the wish details page for wish "Another Joe The Wishers Wish"
    And I follow "fill this request"
    And I fill info_hash field with info hash hex for torrent "Joe The Users Torrent"
    And I press "Confirm"
    Then I should see "Torrent already used to fill another request."









