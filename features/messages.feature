
Feature: Messages
  In order communicate with other users
  As a registered user
  I want to be able to use the messenger system

  Scenario: Sending a message
    Given I am logged in as JOE_THE_USER with role USER
    And I have a user with username JOE_THE_RECEIVER and with role USER
    When I go to the new message page
    And I fill in to with JOE_THE_RECEIVER
    And I fill in message_subject with HELLO
    And I fill in message_body with WASSUP
    And I press Send
    Then I should see Message successfully sent.
    And a new message should be received by JOE_THE_RECEIVER with subject HELLO and with body WASSUP

  Scenario: Sending a system notification
    Given I have a user with username JOE_THE_RECEIVER and with role USER
    When application sends a system notification to JOE_THE_RECEIVER with subject SYSTEM_MESSAGE and body MESSAGE_BODY
    Then a new message should be received by JOE_THE_RECEIVER with subject SYSTEM_MESSAGE and with body MESSAGE_BODY

  Scenario: Browsing a messenger folder
    Given I am logged in as JOE_THE_USER with role USER
    And I have a user with username JOE_THE_SENDER and with role USER
    And I have a new message to JOE_THE_USER sent from JOE_THE_SENDER in folder INBOX with subject HELLO
    And I have a new message to JOE_THE_USER sent from JOE_THE_SENDER in folder INBOX with subject WASSUP
    When I go to the messenger page for folder INBOX
    Then I should see JOE_THE_SENDER
    Then I should see HELLO
    Then I should see WASSUP

  Scenario: Reading a message
    Given I am logged in as JOE_THE_USER with role USER
    And I have a user with username JOE_THE_SENDER and with role USER
    And I have a new message to JOE_THE_USER sent from JOE_THE_SENDER in folder INBOX with subject HELLO
    When I go to the messenger page for folder INBOX
    And I follow the link HELLO
    Then I should see JOE_THE_SENDER
    And I should see HELLO
    And the message sent by JOE_THE_SENDER with subject HELLO should be set as read

  Scenario: Replying a message
    Given I am logged in as JOE_THE_USER with role USER
    And I have a user with username JOE_THE_SENDER and with role USER
    And I have a new message to JOE_THE_USER sent from JOE_THE_SENDER in folder INBOX with subject HELLO
    When I go to the messenger page for folder INBOX
    And I follow the link HELLO
    And I follow the link [ reply ]
    Then I should see New message
    And I should see Re: HELLO
    And I should see JOE_THE_SENDER wrote:

  Scenario: Forwarding a message
    Given I am logged in as JOE_THE_USER with role USER
    And I have a user with username JOE_THE_SENDER and with role USER
    And I have a new message to JOE_THE_USER sent from JOE_THE_SENDER in folder INBOX with subject HELLO
    When I go to the messenger page for folder INBOX
    And I follow the link HELLO
    And I follow the link [ forward ]
    Then I should see New message
    And I should see Fwd: HELLO
    And I should see JOE_THE_SENDER wrote:

  Scenario: Moving a message when reading
    Given I am logged in as JOE_THE_USER with role USER
    And I have a user with username JOE_THE_SENDER and with role USER
    And I have a new message to JOE_THE_USER sent from JOE_THE_SENDER in folder INBOX with subject HELLO
    When I go to the messenger page for folder INBOX
    And I follow the link HELLO
    And I select Trash from destination_folder
    And I press Move to:
    Then I should see Message successfully moved.
    And I should see Folder is Empty
    And the folder for message sent by JOE_THE_SENDER with subject HELLO should be equal to TRASH

  Scenario: Moving a message when browsing a folder
    Given I am logged in as JOE_THE_USER with role USER
    And I have a user with username JOE_THE_SENDER and with role USER
    And I have a new message to JOE_THE_USER sent from JOE_THE_SENDER in folder INBOX with subject HELLO
    When I go to the messenger page for folder INBOX
    And I check selected_messages_
    And I select Trash from destination_folder
    And I press Move to:
    Then I should see Message\(s\) successfully moved.
    And I should see Folder is Empty
    And the folder for message sent by JOE_THE_SENDER with subject HELLO should be equal to TRASH





