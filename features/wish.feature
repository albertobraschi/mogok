
Feature: Wish
  In order to request inexistent torrents
  As a registered user
  I want to be able to create new wishes

  Scenario: Creating a wish
    Given I am logged in as JOE_THE_USER with role USER
    And user with username JOE_THE_USER has a ticket with name wisher
    And I have a type with name AUDIO
    And I have a category with name MUSIC and with type AUDIO
    And I have a format with name MP3 and with type AUDIO
    When I go to the new wish page
    And I select MUSIC from wish_category_id
    And I fill in wish_name with JOE_THE_USERS_WISH
    And I select MP3 from format_id
    And I press Create
    Then a wish with name JOE_THE_USERS_WISH should be created