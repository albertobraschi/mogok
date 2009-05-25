
Feature: System Notification
  In order to automatically notify users
  As a system developer
  I want to be able to ask the application to send system messages

  Scenario: Application sends a system notification
    Given I have a user with username "joe-the-receiver" and with role "user"
    When application sends a system notification to "joe-the-receiver" with subject "from system" and body "Msg body."
    Then a system message with body containing "Msg body." and subject "from system" should be received by "joe-the-receiver"
