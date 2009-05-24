
Feature: Wish Filling
  In order to make wishers happy and eventually be rewarded
  As a registered user
  I want to be able to fill wishes

  Scenario: Filling a wish
    Given I am logged in as JOE_THE_USER with role USER
    And I have a torrent with name JOE_THE_USERS_TORRENT and owned by user JOE_THE_USER
    And I have a user with username JOE_THE_WISHER and with role USER
    And I have a wish with name JOE_THE_WISHERS_WISH and owned by user JOE_THE_WISHER
    When I go to the wish details page for wish JOE_THE_WISHERS_WISH
    And I follow the link fill this request
    And I fill in info_hash with 54B1A5052B5B7D3BA4760F3BFC1135306A30FFD1
    And I press Confirm
    Then I should see Request successfully filled
    And wish with name JOE_THE_WISHERS_WISH should be set to pending
    And wish with name JOE_THE_WISHERS_WISH should have filler set to JOE_THE_USER
    And wish with name JOE_THE_WISHERS_WISH should have torrent set to JOE_THE_USERS_TORRENT
    And a moderation report for wish JOE_THE_WISHERS_WISH should be created

  Scenario: Trying to fill your own wish
    Given I am logged in as JOE_THE_USER with role USER
    And I have a wish with name JOE_THE_USERS_WISH and owned by user JOE_THE_USER
    And I have a torrent with name JOE_THE_USERS_TORRENT and owned by user JOE_THE_USER
    When I go to the wish filling page for wish JOE_THE_USERS_WISH
    Then I should see Access Denied

  Scenario: Filling a wish with an invalid torrent info hash
    Given I am logged in as JOE_THE_USER with role USER
    And I have a user with username JOE_THE_WISHER and with role USER
    And I have a wish with name JOE_THE_WISHERS_WISH and owned by user JOE_THE_WISHER
    When I go to the wish details page for wish JOE_THE_WISHERS_WISH
    And I follow the link fill this request
    And I fill in info_hash with INVALID_INFO_HASH
    And I press Confirm
    Then I should see Invalid torrent info hash.

  Scenario: Filling a wish with someone else's torrent
    Given I am logged in as JOE_THE_USER with role USER
    And I have a user with username JOE_THE_OWNER and with role USER
    And I have a torrent with name JOE_THE_OWNERS_TORRENT and owned by user JOE_THE_OWNER
    And I have a user with username JOE_THE_WISHER and with role USER
    And I have a wish with name JOE_THE_WISHERS_WISH and owned by user JOE_THE_WISHER
    When I go to the wish details page for wish JOE_THE_WISHERS_WISH
    And I follow the link fill this request
    And I fill in info_hash with 54B1A5052B5B7D3BA4760F3BFC1135306A30FFD1
    And I press Confirm
    Then I should see Only the torrent uploader can use it to fill a request.

  Scenario: Filling two wishes with the same torrent
    Given I am logged in as JOE_THE_USER with role USER
    And I have a torrent with name JOE_THE_USERS_TORRENT and owned by user JOE_THE_USER
    And I have a user with username JOE_THE_WISHER and with role USER
    And I have a wish with name JOE_THE_WISHERS_WISH and owned by user JOE_THE_WISHER
    And wish JOE_THE_WISHERS_WISH was filled and approved with torrent JOE_THE_USERS_TORRENT
    And I have a wish with name ANOTHER_JOE_THE_WISHERS_WISH and owned by user JOE_THE_WISHER
    When I go to the wish details page for wish ANOTHER_JOE_THE_WISHERS_WISH
    And I follow the link fill this request
    And I fill in info_hash with 54B1A5052B5B7D3BA4760F3BFC1135306A30FFD1
    And I press Confirm
    Then I should see Torrent already filled another request.









