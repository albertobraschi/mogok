
Feature: Messenger
  In order to communicate with other users
  As a registered user
  I want to be able to use the messenger system

  Background:
    Given I am logged in as "joe-the-user" with role "user"

  Scenario: Sending a message
    Given I have a user with username "joe-the-receiver" and with role "user"
    When I go to the new message page
    And I fill in "to" with "joe-the-receiver"
    And I fill in "message_subject" with "hello"
    And I fill in "message_body" with "Hello msg."
    And I press "Send"
    Then I should see "Message successfully sent."
    And a new message with body containing "Hello msg." and subject "hello" should be received by "joe-the-receiver"

  Scenario: Browsing a messenger folder
    Given I have a user with username "joe-the-sender" and with role "user"
    And I have a new message to "joe-the-user" in folder "inbox" sent by "joe-the-sender" with subject "hello"
    And I have a new message to "joe-the-user" in folder "inbox" sent by "joe-the-sender" with subject "wassup"
    When I go to the messenger page for folder "inbox"
    Then I should see "Inbox"
    And I should see "joe-the-sender"
    And I should see "hello"
    And I should see "wassup"

  Scenario: Reading a message
    Given I have a user with username "joe-the-sender" and with role "user"
    And I have a new message to "joe-the-user" in folder "inbox" sent by "joe-the-sender" with subject "hello"
    When I go to the messenger page for folder "inbox"
    And I follow "hello"
    Then I should see "joe-the-sender"
    And I should see "hello"
    And the message sent by "joe-the-sender" with subject "hello" should be set as read

  Scenario: Replying a message
    Given I have a user with username "joe-the-sender" and with role "user"
    And I have a new message to "joe-the-user" in folder "inbox" sent by "joe-the-sender" with subject "hello"
    When I go to the messenger page for folder "inbox"
    And I follow "hello"
    And I follow "[ reply ]"
    And I press "Send"
    Then a new message with body containing "joe-the-sender wrote:" and subject "Re: hello" should be received by "joe-the-sender"

  Scenario: Forwarding a message
    Given I have a user with username "joe-the-sender" and with role "user"
    And I have a new message to "joe-the-user" in folder "inbox" sent by "joe-the-sender" with subject "hello"
    When I go to the messenger page for folder "inbox"
    And I follow "hello"
    And I follow "[ forward ]"
    And I fill in "to" with "joe-the-sender"
    And I press "Send"
    Then a new message with body containing "joe-the-sender wrote:" and subject "Fwd: hello" should be received by "joe-the-sender"

  Scenario: Moving a message when reading
    Given I have a user with username "joe-the-sender" and with role "user"
    And I have a new message to "joe-the-user" in folder "inbox" sent by "joe-the-sender" with subject "hello"
    When I go to the messenger page for folder "inbox"
    And I follow "hello"
    And I select "Trash" from "destination_folder"
    And I press "Move to:"
    Then I should see "Message successfully moved."
    And I should see "Folder is Empty"
    And the folder for message sent by "joe-the-sender" to "joe-the-user" with subject "hello" should be equal to "trash"

  Scenario: Moving a message when browsing a folder
    Given I have a user with username "joe-the-sender" and with role "user"
    And I have a new message to "joe-the-user" in folder "inbox" sent by "joe-the-sender" with subject "hello"
    When I go to the messenger page for folder "inbox"
    And I check "selected_messages_"
    And I select "Trash" from "destination_folder"
    And I press "Move to:"
    Then I should see "Message(s) successfully moved."
    And I should see "Folder is Empty"
    And the folder for message sent by "joe-the-sender" to "joe-the-user" with subject "hello" should be equal to "trash"





