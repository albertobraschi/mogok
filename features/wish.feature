
Feature: Wish
  In order to request inexistent torrents
  As a registered user
  I want to be able to create new wishes

  Background:
    Given I am logged in as "joe-the-user" with role "user"

  Scenario: Creating a wish
    Given user with username "joe-the-user" has a ticket with name "wisher"
    And I have a type with name "audio"
    And I have a category with name "music" and with type "audio"
    And I have a format with name "ogg" and with type "audio"
    When I go to the new wish page
    And I select "music" from "wish_category_id"
    And I fill in "wish_name" with "Joe The Users Wish"
    And I select "ogg" from "format_id"
    And I press "Create"
    Then a wish with name "Joe The Users Wish" should be created