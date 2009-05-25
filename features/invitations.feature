
Feature: Invitations
  In order to invite people to the site
  As a registered user with invatation rights
  I want to be able to send invitations

  Background:
    Given that signup is open
    And I am logged in as "joe-the-user" with role "user"
    And user "joe-the-user" has a ticket with name "inviter"

  Scenario: Sending an invitation
    When I go to the invitations page
    And I follow "[ invite ]"
    And I fill in "email" with "some-friend@mail.com"
    And I press "Send"
    Then I should see "An invitation email was sent to some-friend@mail.com."
    And an invitation record with email "some-friend@mail.com" and owned by "joe-the-user" should be created
    And I should see the code for invitation with email "some-friend@mail.com" and owned by "joe-the-user"

  Scenario: Cancelling an invitation
    Given I have an invitation with email "some-friend@mail.com" and created by "joe-the-user"
    When I go to the invitations page
    And I follow "[ cancel ]"
    Then I should see "Invitation successfully cancelled."
    And I should see "No invitations found."







