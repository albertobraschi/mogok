
Feature: Torrent upload
  In order to have my torrents in the system
  As a registered user
  I want to be able to upload them

  Scenario: Upload succeeds
    Given I am logged in as JOE_THE_USER with role USER
    And I have a type with name AUDIO
    And I have a category with name MUSIC and with type AUDIO
    And I have a format with name MP3 and with type AUDIO
    And I have a tag with name BLUES and with category MUSIC
    And I have a tag with name POP and with category MUSIC
    When I go to the torrent upload page
    And I select MUSIC from torrent_category_id
    And I specify file field torrent_file as VALID.TORRENT
    And I fill in torrent_name with MY_VALID_TORRENT
    And I select MP3 from format_id
    And I fill in tags_str with BLUES, POP
    And I press Upload
    Then I should see MY_VALID_TORRENT
    And I should see MUSIC
    And I should see MP3
    And I should see BLUES
    And I should see POP
    And I should see 54B1A5052B5B7D3BA4760F3BFC1135306A30FFD1
    And the torrent MY_VALID_TORRENT should have 3 mapped files
    And the torrent MY_VALID_TORRENT should have 65536 as piece length
    And the torrent MY_VALID_TORRENT should have 2 tags

  Scenario: An invalid torrent file is uploaded
    Given I am logged in as JOE_THE_USER with role USER
    And I have a type with name AUDIO
    And I have a category with name MUSIC and with type AUDIO
    When I go to the torrent upload page
    And I specify file field torrent_file as INVALID.TORRENT
    And I select MUSIC from torrent_category_id
    And I fill in torrent_name with MY_INVALID_TORRENT
    And I press Upload
    Then I should see Invalid torrent file.

  Scenario: A file of another type is uploaded
    Given I am logged in as JOE_THE_USER with role USER
    And I have a type with name AUDIO
    And I have a category with name MUSIC and with type AUDIO
    When I go to the torrent upload page
    And I specify file field torrent_file as TEST.TXT
    And I select MUSIC from torrent_category_id
    And I fill in torrent_name with MY_INVALID_FILE
    And I press Upload
    Then I should see Must be a file of type torrent






