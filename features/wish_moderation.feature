
Feature: Wish Moderation
  In order to moderate wishes
  As a moderator
  I want to be able to approve or reject wish fillings

  Background:
    Given I am logged in as "joe-the-mod" with role "mod"

  Scenario: Rejecting a wish filling
    Given I have a user with username "joe-the-wisher" and with role "user"
    And I have a wish with name "joe-the-wishers-wish" and owned by user "joe-the-wisher"
    And I have a user with username "joe-the-filler" and with role "user"
    And I have a torrent with name "joe-the-fillers-torrent" and owned by user "joe-the-filler"
    And wish "joe-the-wishers-wish" was filled with torrent "joe-the-fillers-torrent"
    When I go to the wish details page for wish "joe-the-wishers-wish"
    And I follow "reject"
    And I fill in "reason" with "Whatever Reason"
    And I press "Confirm"
    Then I should see "Request filling successfully rejected."
    And wish with name "joe-the-wishers-wish" should be set to not pending
    And filler for wish with name "joe-the-wishers-wish" should be empty
    And torrent for wish with name "joe-the-wishers-wish" should be empty
    And a message should be sent to "joe-the-filler" with subject "request filling rejected"

  Scenario: Approve a wish filling with bounty transfer
    Given I have a user with username "joe-the-wisher" and with role "user"
    And I have a wish with name "joe-the-wishers-wish" and owned by user "joe-the-wisher"
    And I have a wish bounty for wish "joe-the-wishers-wish" with amount of 10485760 created by "joe-the-wisher"
    And I have a user with username "joe-the-filler" and with role "user"
    And user with username "joe-the-filler" has 0 as uploaded
    And I have a torrent with name "joe-the-fillers-torrent" and owned by user "joe-the-filler"
    And wish "joe-the-wishers-wish" was filled with torrent "joe-the-fillers-torrent"
    When I go to the wish details page for wish "joe-the-wishers-wish"
    And I follow "approve"
    Then I should see "Request filling successfully approved."
    And wish with name "joe-the-wishers-wish" should be set to not pending
    And wish with name "joe-the-wishers-wish" should be set to filled
    And user with username "joe-the-filler" should have uploaded equal to 10485760
    And a message should be sent to "joe-the-filler" with subject "request filling approved"