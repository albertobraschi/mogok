
Feature: Forums
  In order to discuss ideas
  As a registered user
  I want to be able to publish content in the forums

  Background:
    Given I am logged in as "joe-the-user" with role "user"
    And I have a forum with name "Whatever Forum"

  Scenario: A user creates a topic in a forum
    When I go to the forum page for forum "Whatever Forum"
    And I follow "[ new topic ]"
    And I fill in "title" with "Topic title."
    And I fill in "body" with "Topic post body."
    And I press "Create"
    Then I should see "Topic successfully created."
    And a topic in forum "Whatever Forum" with title "Topic title." and owned by user "joe-the-user" should be created
    And the topic post for topic "Topic title." should have body equal to "Topic post body."

  Scenario: A user creates a post in a topic
    Given I have a topic in forum "Whatever Forum" with title "Joe The Users Topic" and body "Topic post body." and owned by user "joe-the-user"
    When I go to the forum page for forum "Whatever Forum"
    And I follow "Joe The Users Topic"
    And I fill in "post_body" with "Post body."
    And I press "Submit"
    Then I should see "Post successfully added."
    And I should see "Post body."
    And a post in topic "Joe The Users Topic" with body "Post body." and owned by user "joe-the-user" should be created

  Scenario: A user reports a topic
    Given I have a user with username "joe-the-owner" and with role "user"
    And I have a topic in forum "Whatever Forum" with title "Joe The Owners Topic" and body "Topic post body." and owned by user "joe-the-owner"
    When I go to the forum page for forum "Whatever Forum"
    And I follow "Joe The Owners Topic"
    And I follow "report"
    And I fill in "reason" with "Whatever Reason"
    And I press "Send"
    Then I should see "Topic successfully reported."
    And a moderation report for topic "Joe The Owners Topic" with reason "Whatever Reason" should be created



