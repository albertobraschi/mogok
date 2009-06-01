
Feature: Wish Moderation
  In order to moderate wish fillings
  As a moderator
  I want to be able to approve or reject them

  Background:
    Given I am logged in as "joe-the-mod" with role "mod"

  Scenario: A wish filling is rejected
    Given I have a user with username "joe-the-wisher" and with role "user"
    And I have a user with username "joe-the-filler" and with role "user"
    And I have a wish with name "Joe The Wishers Wish" and created by user "joe-the-wisher"
    And I have a torrent with name "Joe The Fillers Torrent" and created by user "joe-the-filler"
    And wish "Joe The Wishers Wish" was filled with torrent "Joe The Fillers Torrent"
    When I go to the wish details page for wish "Joe The Wishers Wish"
    And I follow "reject"
    And I fill in "reason" with "Whatever Reason"
    And I press "Confirm"
    Then I should see "Request filling successfully rejected."
    And wish "Joe The Wishers Wish" should be set to not pending
    And filler for wish "Joe The Wishers Wish" should be empty
    And torrent for wish "Joe The Wishers Wish" should be empty
    And a system message with subject "request filling rejected" should be received by "joe-the-filler"
        
  Scenario: A wish filling with bounty transfer is approved
    Given I have a user with username "joe-the-wisher" and with role "user"
    And I have a user with username "joe-the-filler" and with role "user"
    And user "joe-the-filler" has uploaded equal to 0
    And I have a user with username "joe-the-bounter" and with role "user"
    And I have a wish with name "Joe The Wishers Wish" and created by user "joe-the-wisher"
    And I have a torrent with name "Joe The Fillers Torrent" and created by user "joe-the-filler"
    And I have a wish bounty for wish "Joe The Wishers Wish" with amount of 10485760 created by "joe-the-bounter"
    And wish "Joe The Wishers Wish" was filled with torrent "Joe The Fillers Torrent"    
    When I go to the wish details page for wish "Joe The Wishers Wish"
    And I follow "approve"
    Then I should see "Request filling successfully approved."
    And wish "Joe The Wishers Wish" should be set to not pending
    And wish "Joe The Wishers Wish" should be set to filled
    And user "joe-the-filler" should have uploaded equal to 10485760
    And a system message with subject "your request was filled" should be received by "joe-the-wisher"
    And a system message with subject "request filling approved" should be received by "joe-the-filler"
    And a system message with subject "request filled" should be received by "joe-the-bounter"



