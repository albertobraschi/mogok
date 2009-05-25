
Feature: System Notification
  In order to automatically notify users
  As a system developer
  I want to be able to send messages as system user

  Background:
    Given I have a system user

  Scenario: Sending a system notification
    Given I have a user with username "joe-the-receiver" and with role "user"
    When application sends a system notification to "joe-the-receiver" with subject "system-notification" and body "notification-body"
    Then a new system message should be received by "joe-the-receiver" with subject "system-notification" and body "notification-body"
