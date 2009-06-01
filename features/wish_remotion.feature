
Feature: Wish Remotion
  In order to remove wishs from the site
  As a registered user or a moderator
  I want to be able to remove them

  Scenario: A user removes it own wish
    Given I am logged in as "joe-the-user" with role "user"
    And I have a wish with name "Joe The Users Wish" and created by user "joe-the-user"
    When I go to the wish details page for wish "Joe The Users Wish"
    And I follow "remove"
    And I fill in "reason" with "Whatever Reason"
    And I press "Remove"
    Then I should see "Request successfully removed."
    And wish "Joe The Users Wish" should be deleted

  Scenario: A moderator removes another users wish
    Given I am logged in as "joe-the-mod" with role "mod"
    And I have a user with username "joe-the-wisher" and with role "user"
    And I have a wish with name "Joe The Wishers Wish" and created by user "joe-the-wisher"
    When I go to the wish details page for wish "Joe The Wishers Wish"
    And I follow "remove"
    And I fill in "reason" with "Whatever Reason"
    And I press "Remove"
    Then I should see "Request successfully removed."
    And wish "Joe The Wishers Wish" should be deleted
    And a system message with subject "request removed" should be received by "joe-the-wisher"