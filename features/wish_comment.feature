
Feature: Wish comment
  In order to give my opinion about a wish
  As a registered user
  I want to be able to add comments to it

  Background:
    Given I am logged in as "joe-the-user" with role "user"

  Scenario: A user adds a comment to a wish
    Given I have a wish with name "Joe The Users Wish" and owned by user "joe-the-user"
    When I go to the wish details page for wish "Joe The Users Wish"
    And I fill in "comment_body" with "Comment body."
    And I press "Submit"
    Then I should see "Request Details"
    And I should see "Comment successfully added."
    And a comment by user "joe-the-user" with body equal to "Comment body." should be created for wish "Joe The Users Wish"

  Scenario: A user edits its own wish comment
    Given I have a user with username "joe-the-wisher" and with role "user"
    And I have a wish with name "Joe The Wishers Wish" and owned by user "joe-the-wisher"
    And I have a comment by user "joe-the-user" for wish "Joe The Wishers Wish" with body equal to "Comment body."
    When I go to the wish details page for wish "Joe The Wishers Wish"
    And I follow "edit"
    And I fill in "comment_body" with "Edited comment body."
    And I press "Edit"
    Then I should see "Request Details"
    And I should see "Comment successfully edited."
    And I should see "Edited comment body."
