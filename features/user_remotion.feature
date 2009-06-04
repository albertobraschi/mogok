
Feature: User Remotion
  In order to remove users from the site
  As an administrator
  I want to be able to remove them

  Scenario: A user is removed from the system
    Given I am logged in as "joe-the-admin" with role "admin"
    And I have a user with username "joe-the-user" and with role "user"
    When I go to the user details page for user "joe-the-user"
    And I follow "remove"
    And I press "Remove"
    Then I should see "User successfully destroyed."
    And user "joe-the-user" should be deleted

