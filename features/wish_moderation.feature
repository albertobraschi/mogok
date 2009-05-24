
Feature: Wish Moderation
  In order to moderate wishes
  As a moderator
  I want to be able to approve or reject wish fillings

  Scenario: Rejecting a wish filling
    Given I am logged in as JOE_THE_MOD with role MOD
    And I have a user with username JOE_THE_WISHER and with role USER
    And I have a wish with name JOE_THE_WISHERS_WISH and owned by user JOE_THE_WISHER
    And I have a user with username JOE_THE_FILLER and with role USER
    And I have a torrent with name JOE_THE_FILLERS_TORRENT and owned by user JOE_THE_FILLER
    And wish JOE_THE_WISHERS_WISH was filled with torrent JOE_THE_FILLERS_TORRENT
    When I go to the wish details page for wish JOE_THE_WISHERS_WISH
    And I follow the link reject
    And I fill in reason with Whatever Reason
    And I press Confirm
    Then I should see Request filling successfully rejected.
    And wish with name JOE_THE_WISHERS_WISH should be set to not pending
    And filler for wish with name JOE_THE_WISHERS_WISH should be empty
    And torrent for wish with name JOE_THE_WISHERS_WISH should be empty
    And a message should be sent to JOE_THE_FILLER with subject request filling rejected

  Scenario: Approve a wish filling with bounty transfer
    Given I am logged in as JOE_THE_MOD with role MOD
    And I have a user with username JOE_THE_WISHER and with role USER
    And I have a wish with name JOE_THE_WISHERS_WISH and owned by user JOE_THE_WISHER
    And I have a wish_bounty for wish JOE_THE_WISHERS_WISH with amount of 10485760 created by JOE_THE_WISHER
    And I have a user with username JOE_THE_FILLER and with role USER
    And user with username JOE_THE_FILLER has 0 as uploaded
    And I have a torrent with name JOE_THE_FILLERS_TORRENT and owned by user JOE_THE_FILLER
    And wish JOE_THE_WISHERS_WISH was filled with torrent JOE_THE_FILLERS_TORRENT
    When I go to the wish details page for wish JOE_THE_WISHERS_WISH
    And I follow the link approve
    Then I should see Request filling successfully approved.
    And wish with name JOE_THE_WISHERS_WISH should be set to not pending
    And wish with name JOE_THE_WISHERS_WISH should be set to filled
    And user with username JOE_THE_FILLER should have uploaded equal to 10485760
    And a message should be sent to JOE_THE_FILLER with subject request filling approved