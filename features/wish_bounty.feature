
Feature: Wish Bounty
  In order to reward wish fillers
  As a registered user
  I want to be able to add bounties to wishes

  Scenario: Adding a bounty to a wish
    Given I am logged in as JOE_THE_USER with role USER
    And user with username JOE_THE_USER has 10485760 as uploaded
    And I have a wish with name JOE_THE_USERS_WISH and owned by user JOE_THE_USER
    When I go to the wish details page for wish JOE_THE_USERS_WISH
    And I follow the link bounties
    And I follow the link [ add bounty ]
    And I fill in bounty_amount with 10
    And I select MB from bounty_unit
    And I press Confirm
    Then I should see Request bounty successfully added.
    And a wish_bounty with amount 10485760 should be created for wish JOE_THE_USERS_WISH
    And wish with name JOE_THE_USERS_WISH should have total_bounty equal to 10485760
    And user with username JOE_THE_USER should have uploaded equal to 0

  Scenario: Adding a bounty to a wish having insufficient upload credit
    Given I am logged in as JOE_THE_USER with role USER
    And user with username JOE_THE_USER has 0 as uploaded
    And I have a wish with name TEST_WISH and owned by user JOE_THE_USER
    When I go to the wish details page for wish TEST_WISH
    And I follow the link bounties
    And I follow the link [ add bounty ]
    And I fill in bounty_amount with 10
    And I select MB from bounty_unit
    And I press Confirm
    Then I should see Your upload credit is insufficient.







