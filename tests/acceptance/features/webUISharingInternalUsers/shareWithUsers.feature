@webUI @insulated @disablePreviews @files_sharing-app-required
Feature: Sharing files and folders with internal users
  As a user
  I want to share files and folders with other users
  So that those users can access the files and folders


  @TestAlsoOnExternalUserBackend
  @smokeTest
  Scenario: share a file & folder with another internal user
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user2" has logged in using the webUI
    When the user shares folder "simple-folder" with user "User One" using the webUI
    And the user shares file "testimage.jpg" with user "User One" using the webUI
    And the user re-logs in as "user1" using the webUI
    Then folder "simple-folder (2)" should be listed on the webUI
    And folder "simple-folder (2)" should be marked as shared by "User Two" on the webUI
    And file "testimage (2).jpg" should be listed on the webUI
    And file "testimage (2).jpg" should be marked as shared by "User Two" on the webUI
    When the user opens folder "simple-folder (2)" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    But folder "simple-folder (2)" should not be listed on the webUI

  @TestAlsoOnExternalUserBackend @skipOnFIREFOX
  Scenario: share a file with another internal user who overwrites and unshares the file
    Given user "user1" has been created with default attributes and without skeleton files
    And user "user2" has been created with default attributes and skeleton files
    And user "user2" has logged in using the webUI
    When the user renames file "lorem.txt" to "new-lorem.txt" using the webUI
    And the user shares file "new-lorem.txt" with user "User One" using the webUI
    And the user re-logs in as "user1" using the webUI
    Then the content of "new-lorem.txt" should not be the same as the local "new-lorem.txt"
		# overwrite the received shared file
    When the user uploads overwriting file "new-lorem.txt" using the webUI and retries if the file is locked
    Then file "new-lorem.txt" should be listed on the webUI
    And the content of "new-lorem.txt" should be the same as the local "new-lorem.txt"
		# unshare the received shared file
    When the user unshares file "new-lorem.txt" using the webUI
    Then file "new-lorem.txt" should not be listed on the webUI
		# check that the original file owner can still see the file
    When the user re-logs in as "user2" using the webUI
    Then the content of "new-lorem.txt" should be the same as the local "new-lorem.txt"

  @TestAlsoOnExternalUserBackend
  Scenario: share a folder with another internal user who uploads, overwrites and deletes files
    Given user "user1" has been created with default attributes and without skeleton files
    And user "user2" has been created with default attributes and skeleton files
    And user "user2" has logged in using the webUI
    When the user renames folder "simple-folder" to "new-simple-folder" using the webUI
    And the user shares folder "new-simple-folder" with user "User One" using the webUI
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "new-simple-folder" using the webUI
    Then the content of "lorem.txt" should not be the same as the local "lorem.txt"
		# overwrite an existing file in the received share
    When the user uploads overwriting file "lorem.txt" using the webUI and retries if the file is locked
    Then file "lorem.txt" should be listed on the webUI
    And the content of "lorem.txt" should be the same as the local "lorem.txt"
		# upload a new file into the received share
    When the user uploads file "new-lorem.txt" using the webUI
    Then the content of "new-lorem.txt" should be the same as the local "new-lorem.txt"
		# delete a file in the received share
    When the user deletes file "data.zip" using the webUI
    Then file "data.zip" should not be listed on the webUI
		# check that the file actions by the sharee are visible for the share owner
    When the user re-logs in as "user2" using the webUI
    And the user opens folder "new-simple-folder" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    And the content of "lorem.txt" should be the same as the local "lorem.txt"
    And file "new-lorem.txt" should be listed on the webUI
    And the content of "new-lorem.txt" should be the same as the local "new-lorem.txt"
    But file "data.zip" should not be listed on the webUI

  @TestAlsoOnExternalUserBackend
  Scenario: share a folder with another internal user who unshares the folder
    Given user "user1" has been created with default attributes and without skeleton files
    And user "user2" has been created with default attributes and skeleton files
    And user "user2" has logged in using the webUI
    When the user renames folder "simple-folder" to "new-simple-folder" using the webUI
    And the user shares folder "new-simple-folder" with user "User One" using the webUI
		# unshare the received shared folder and check it is gone
    And the user re-logs in as "user1" using the webUI
    And the user unshares folder "new-simple-folder" using the webUI
    Then folder "new-simple-folder" should not be listed on the webUI
		# check that the folder is still visible for the share owner
    When the user re-logs in as "user2" using the webUI
    Then folder "new-simple-folder" should be listed on the webUI
    When the user opens folder "new-simple-folder" using the webUI
    Then file "lorem.txt" should be listed on the webUI
    And the content of "lorem.txt" should be the same as the original "simple-folder/lorem.txt"

  @skipOnMICROSOFTEDGE @TestAlsoOnExternalUserBackend @skipOnOcV10.3
  Scenario: share a folder with another internal user and prohibit deleting
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user2" has logged in using the webUI
    When the user shares folder "simple-folder" with user "User One" using the webUI
    And the user sets the sharing permissions of user "User One" for "simple-folder" using the webUI to
      | delete | no |
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "simple-folder (2)" using the webUI
    Then it should not be possible to delete file "lorem.txt" using the webUI

  @skipOnFIREFOX
  Scenario: share a folder with other user and then it should be listed on Shared with You for other user
    Given user "user1" has been created with default attributes and without skeleton files
    And user "user2" has been created with default attributes and skeleton files
    And user "user2" has logged in using the webUI
    And the user has renamed folder "simple-folder" to "new-simple-folder" using the webUI
    And the user has renamed file "lorem.txt" to "ipsum.txt" using the webUI
    And the user has shared file "ipsum.txt" with user "User One" using the webUI
    And the user has shared folder "new-simple-folder" with user "User One" using the webUI
    When the user re-logs in as "user1" using the webUI
    And the user browses to the shared-with-you page
    Then file "ipsum.txt" should be listed on the webUI
    And folder "new-simple-folder" should be listed on the webUI

  Scenario: share a folder with other user and then it should be listed on Shared with Others page
    Given user "user1" has been created with default attributes and without skeleton files
    And user "user2" has been created with default attributes and skeleton files
    And user "user2" has logged in using the webUI
    And the user has shared file "lorem.txt" with user "User One" using the webUI
    And the user has shared folder "simple-folder" with user "User One" using the webUI
    When the user browses to the shared-with-others page
    Then file "lorem.txt" should be listed on the webUI
    And folder "simple-folder" should be listed on the webUI

  Scenario: share two file with same name but different paths
    Given user "user1" has been created with default attributes and without skeleton files
    And user "user2" has been created with default attributes and skeleton files
    And user "user2" has logged in using the webUI
    And the user has shared file "lorem.txt" with user "User One" using the webUI
    When the user opens folder "simple-folder" using the webUI
    And the user shares file "lorem.txt" with user "User One" using the webUI
    And the user browses to the shared-with-others page
    Then file "lorem.txt" with path "" should be listed in the shared with others page on the webUI
    And file "lorem.txt" with path "/simple-folder" should be listed in the shared with others page on the webUI

  Scenario: user tries to share a file from a group which is blacklisted from sharing
    Given group "grp1" has been created
    And these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user3    |
    And user "user2" has been created with default attributes and skeleton files
    And user "user1" has been added to group "grp1"
    And the administrator has browsed to the admin sharing settings page
    When the administrator enables exclude groups from sharing using the webUI
    And the administrator adds group "grp1" to the exclude group from sharing list using the webUI
    Then user "user1" should not be able to share file "testimage.jpg" with user "user3" using the sharing API

  Scenario: user tries to share a folder from a group which is blacklisted from sharing
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user3    |
    And user "user2" has been created with default attributes and skeleton files
    And group "grp1" has been created
    And user "user1" has been added to group "grp1"
    And the administrator has browsed to the admin sharing settings page
    When the administrator enables exclude groups from sharing using the webUI
    And the administrator adds group "grp1" to the exclude group from sharing list using the webUI
    Then user "user1" should not be able to share folder "simple-folder" with user "User Three" using the sharing API

  Scenario: member of a blacklisted from sharing group tries to re-share a file received as a share
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user1    |
      | user3    |
    And these users have been created with default attributes and without skeleton files:
      | username |
      | user2    |
      | user4    |
    And group "grp1" has been created
    And user "user1" has been added to group "grp1"
    And user "user3" has shared file "/testimage.jpg" with user "user1"
    And the administrator has enabled exclude groups from sharing
    And the administrator has browsed to the admin sharing settings page
    When the administrator adds group "grp1" to the exclude group from sharing list using the webUI
    Then user "user1" should not be able to share file "/testimage (2).jpg" with user "User Four" using the sharing API

  Scenario: member of a blacklisted from sharing group tries to re-share a folder received as a share
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
      | user3    |
      | user4    |
    And group "grp1" has been created
    And user "user1" has been added to group "grp1"
    And user "user3" has created folder "/common"
    And user "user3" has shared folder "/common" with user "user1"
    And the administrator has enabled exclude groups from sharing
    And the administrator has browsed to the admin sharing settings page
    When the administrator adds group "grp1" to the exclude group from sharing list using the webUI
    Then user "user1" should not be able to share folder "/common" with user "User Four" using the sharing API

  Scenario: member of a blacklisted from sharing group tries to re-share a file inside a folder received as a share
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
      | user4    |
    And user "user3" has been created with default attributes and skeleton files
    And group "grp1" has been created
    And user "user1" has been added to group "grp1"
    And user "user3" has created folder "/common"
    And user "user3" has moved file "/testimage.jpg" to "/common/testimage.jpg"
    And user "user3" has shared folder "/common" with user "user1"
    And the administrator has enabled exclude groups from sharing
    And the administrator has browsed to the admin sharing settings page
    When the administrator adds group "grp1" to the exclude group from sharing list using the webUI
    Then user "user1" should not be able to share file "/common/testimage.jpg" with user "User Four" using the sharing API

  Scenario: member of a blacklisted from sharing group tries to re-share a folder inside a folder received as a share
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
      | user3    |
      | user4    |
    And user "user3" has created folder "/common"
    And user "user3" has created folder "/common/inside-common"
    And user "user3" has shared folder "/common" with user "user1"
    And the administrator has enabled exclude groups from sharing
    And the administrator has browsed to the admin sharing settings page
    When the administrator adds group "grp1" to the exclude group from sharing list using the webUI
    Then user "user1" should not be able to share folder "/common/inside-common" with user "User Four" using the sharing API

  Scenario: user tries to share a file from a group which is blacklisted from sharing using webUI from files page
    Given group "grp1" has been created
    And user "user1" has been created with default attributes and skeleton files
    And user "user1" has been added to group "grp1"
    And the administrator has enabled exclude groups from sharing
    And the administrator has browsed to the admin sharing settings page
    When the administrator adds group "grp1" to the exclude group from sharing list using the webUI
    And the user re-logs in as "user1" using the webUI
    And the user opens the sharing tab from the file action menu of file "testimage.jpg" using the webUI
    Then the user should see an error message on the share dialog saying "Sharing is not allowed"
    And the share-with field should not be visible in the details panel

  Scenario: user tries to re-share a file from a group which is blacklisted from sharing using webUI from shared with you page
    Given group "grp1" has been created
    And these users have been created with default attributes and skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user1" has been added to group "grp1"
    And user "user3" has been created with default attributes and without skeleton files
    And user "user2" has shared file "/testimage.jpg" with user "user1"
    And the administrator has enabled exclude groups from sharing
    And the administrator has browsed to the admin sharing settings page
    When the administrator adds group "grp1" to the exclude group from sharing list using the webUI
    And the user re-logs in as "user1" using the webUI
    And the user browses to the shared-with-you page
    And the user opens the sharing tab from the file action menu of file "testimage (2).jpg" using the webUI
    Then the user should see an error message on the share dialog saying "Sharing is not allowed"
    And the share-with field should not be visible in the details panel
    And user "user1" should not be able to share file "testimage (2).jpg" with user "User Three" using the sharing API

  Scenario: user shares the file/folder with another internal user and delete the share with user
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user1" has logged in using the webUI
    And user "user1" has shared file "lorem.txt" with user "user2"
    When the user opens the share dialog for file "lorem.txt"
    And the user deletes share with user "User Two" for the current file
    Then the user "User Two" should not be in share with user list
    And file "lorem.txt" should not be listed in shared-with-others page on the webUI
    And as "user2" file "lorem (2).txt" should not exist

  @skipOnEncryptionType:user-keys @issue-encryption-126
  @mailhog
  Scenario: user should be able to send notification by email when allow share mail notification has been enabled
    Given parameter "shareapi_allow_mail_notification" of app "core" has been set to "yes"
    And user "user1" has been created with default attributes and skeleton files
    And user "user2" has been created with default attributes and without skeleton files
    And user "user1" has logged in using the webUI
    And user "user1" has shared file "lorem.txt" with user "user2"
    And the user has opened the share dialog for file "lorem.txt"
    When the user sends the share notification by email using the webUI
    Then a notification should be displayed on the webUI with the text "Email notification was sent!"
    And the email address "user2@example.org" should have received an email with the body containing
      """
      just letting you know that User One shared lorem.txt with you.
      """

  @mailhog
  Scenario: user should get and error message when trying to send notification by email to a user who has not setup their email
    Given parameter "shareapi_allow_mail_notification" of app "core" has been set to "yes"
    And user "user1" has been created with default attributes and skeleton files
    And these users have been created without skeleton files:
      | username | password |
      | user0    | 1234     |
    And user "user1" has logged in using the webUI
    And user "user1" has shared file "lorem.txt" with user "user0"
    And the user has opened the share dialog for file "lorem.txt"
    When the user sends the share notification by email using the webUI
    Then dialog should be displayed on the webUI
      | title                       | content                                             |
      | Email notification not sent | Couldn't send mail to following recipient(s): user0 |

  @mailhog
  Scenario: user should not be able to send notification by email more than once
    Given parameter "shareapi_allow_mail_notification" of app "core" has been set to "yes"
    And user "user1" has been created with default attributes and skeleton files
    And user "user2" has been created with default attributes and without skeleton files
    And user "user1" has logged in using the webUI
    And user "user1" has shared file "lorem.txt" with user "user2"
    And the user has opened the share dialog for file "lorem.txt"
    When the user sends the share notification by email using the webUI
    Then the user should not be able to send the share notification by email using the webUI
    When the user reloads the current page of the webUI
    And the user opens the share dialog for file "lorem.txt"
    Then the user should not be able to send the share notification by email using the webUI

  Scenario: user should not be able to send notification by email when allow share mail notification has been disabled
    Given parameter "shareapi_allow_mail_notification" of app "core" has been set to "no"
    And user "user1" has been created with default attributes and skeleton files
    And user "user2" has been created with default attributes and without skeleton files
    And user "user1" has logged in using the webUI
    And user "user1" has shared file "lorem.txt" with user "user2"
    When the user opens the share dialog for file "lorem.txt"
    Then the user should not be able to send the share notification by email using the webUI

  Scenario: user shares a file with another user with uppercase username
    Given user "user1" has been created with default attributes and skeleton files
    And these users have been created without skeleton files:
      | username |
      | SomeUser |
    And user "user1" has logged in using the webUI
    When the user shares file "lorem.txt" with user "SomeUser" using the webUI
    And the user re-logs in as "SomeUser" using the webUI
    And the user browses to the shared-with-you page
    Then file "lorem.txt" should be listed on the webUI

  Scenario: multiple users share a file with the same name to a user
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
      | user3    |
    And user "user2" has uploaded file with content "user2 file" to "/randomfile.txt"
    And user "user3" has uploaded file with content "user3 file" to "/randomfile.txt"
    And user "user2" has shared file "randomfile.txt" with user "user1"
    And user "user3" has shared file "randomfile.txt" with user "user1"
    When user "user1" logs in using the webUI
    Then file "randomfile.txt" should be listed on the webUI
    And the content of file "randomfile.txt" for user "user1" should be "user2 file"
    And file "randomfile (2).txt" should be listed on the webUI
    And the content of file "randomfile (2).txt" for user "user1" should be "user3 file"

  Scenario: multiple users share a folder with the same name to a user
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
      | user3    |
    And user "user2" has created folder "/zzzfolder"
    And user "user3" has created folder "/zzzfolder"
    And user "user2" has shared folder "zzzfolder" with user "user1"
    And user "user3" has shared folder "zzzfolder" with user "user1"
    When user "user1" logs in using the webUI
    Then folder "zzzfolder" should be listed on the webUI
    And folder "zzzfolder" should be marked as shared by "User Two" on the webUI
    And folder "zzzfolder (2)" should be listed on the webUI
    And folder "zzzfolder (2)" should be marked as shared by "User Three" on the webUI

  Scenario Outline:  user names are not case-sensitive, sharing same file to user specifying different upper and lower case names
    Given these users have been created with default attributes and without skeleton files:
      | username       |
      | user1          |
      | brand-new-user |
    And user "user1" has created folder "/simple-folder"
    And user "user1" has shared folder "simple-folder" with user "brand-new-user"
    And user "user1" has logged in using the webUI
    And the user has opened the share dialog for folder "simple-folder"
    When the user types "<user_id1>" in the share-with-field
    Then a tooltip with the text "No users or groups found for <user_id1>" should be shown near the share-with-field on the webUI
    When the user types "<user_id2>" in the share-with-field
    Then a tooltip with the text "No users or groups found for <user_id2>" should be shown near the share-with-field on the webUI
    When the user types "<user_id3>" in the share-with-field
    Then a tooltip with the text "No users or groups found for <user_id3>" should be shown near the share-with-field on the webUI
    Examples:
      | user_id1       | user_id2       | user_id3       |
      | Brand-New-User | brand-new-user | BRAND-NEW-USER |
      | brand-new-user | BRAND-NEW-USER | Brand-New-User |
      | BRAND-NEW-USER | Brand-New-User | brand-new-user |

  Scenario: sharer should be able to share a folder to a user when only share with groups they are member of is enabled
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
    And group "grp1" has been created
    And user "user1" has been added to group "grp1"
    And user "user1" has created folder "/simple-folder"
    And the administrator has browsed to the admin sharing settings page
    When the administrator enables restrict users to only share with groups they are member of using the webUI
    And the user re-logs in as "user1" using the webUI
    And the user shares folder "simple-folder" with user "User Two" using the webUI
    Then as "user2" folder "/simple-folder" should exist

  Scenario: sharer should be able to share a file to a user when only share with groups they are member of is enabled
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
    And group "grp1" has been created
    And user "user1" has been added to group "grp1"
    And user "user1" has uploaded file with content "some content" to "lorem.txt"
    And the administrator has browsed to the admin sharing settings page
    When the administrator enables restrict users to only share with groups they are member of using the webUI
    And the user re-logs in as "user1" using the webUI
    And the user shares file "lorem.txt" with user "User Two" using the webUI
    Then as "user2" file "/lorem.txt" should exist

  @skipOnOcV10.3
  Scenario: Create share with share permission only
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
      | user3    |
    And user "user2" has created folder "simple-folder"
    And user "user2" has uploaded file "filesForUpload/lorem.txt" to "simple-folder/lorem.txt"
    And user "user2" has logged in using the webUI
    When the user shares folder "simple-folder" with user "User One" using the webUI
    And the user sets the sharing permissions of user "User One" for "simple-folder" using the webUI to
      | edit | no |
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then the option to rename file "lorem.txt" should not be available on the webUI
    And the option to delete file "lorem.txt" should not be available on the webUI
    And the option to upload file should not be available on the webUI
    # Even though the upload option is not shown in the ui, the file input is still present.
    # So we can attach a file to that input and try to upload.
    When the user uploads file "textfile.txt" using the webUI
    Then as "user1" file "simple-folder/textfile.txt" should not exist
    And file "textfile.txt" should not be listed on the webUI
    When the user shares file "lorem.txt" with user "User Three" using the webUI
    Then as "user3" file "lorem.txt" should exist

  @skipOnOcV10.3
  Scenario: Create share with share and create permission only
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user2" has created folder "simple-folder"
    And user "user2" has uploaded file "filesForUpload/lorem.txt" to "simple-folder/lorem.txt"
    And user "user2" has logged in using the webUI
    When the user shares folder "simple-folder" with user "User One" using the webUI
    And the user sets the sharing permissions of user "User One" for "simple-folder" using the webUI to
      | change | no |
      | delete | no |
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then the option to rename file "lorem.txt" should not be available on the webUI
    And the option to delete file "lorem.txt" should not be available on the webUI
    When the user uploads file "textfile.txt" using the webUI
    Then as "user1" file "simple-folder/textfile.txt" should exist
    And the content of "textfile.txt" should be the same as the local "textfile.txt"

  @skipOnOcV10.3
  Scenario: Create share with share and change permission only
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user2" has created folder "simple-folder"
    And user "user2" has uploaded file "filesForUpload/lorem.txt" to "simple-folder/lorem.txt"
    And user "user2" has logged in using the webUI
    When the user shares folder "simple-folder" with user "User One" using the webUI
    And the user sets the sharing permissions of user "User One" for "simple-folder" using the webUI to
      | create | no |
      | delete | no |
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then the option to rename file "lorem.txt" should be available on the webUI
    And the option to delete file "lorem.txt" should not be available on the webUI
    When the user uploads file "textfile.txt" using the webUI
    Then as "user1" file "simple-folder/textfile.txt" should not exist
    And file "textfile.txt" should not be listed on the webUI

  @skipOnOcV10.3
  Scenario: Create share with share and delete permission only
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user2" has created folder "simple-folder"
    And user "user2" has uploaded file "filesForUpload/lorem.txt" to "simple-folder/lorem.txt"
    And user "user2" has logged in using the webUI
    When the user shares folder "simple-folder" with user "User One" using the webUI
    And the user sets the sharing permissions of user "User One" for "simple-folder" using the webUI to
      | change | no |
      | create | no |
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then the option to rename file "lorem.txt" should not be available on the webUI
    And it should be possible to delete file "lorem.txt" using the webUI
    When the user uploads file "textfile.txt" using the webUI
    Then as "user1" file "simple-folder/textfile.txt" should not exist
    And file "textfile.txt" should not be listed on the webUI

  @skipOnOcV10.3
  Scenario: Create share with edit and without share permissions
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user2" has created folder "simple-folder"
    And user "user2" has uploaded file "filesForUpload/lorem.txt" to "simple-folder/lorem.txt"
    And user "user2" has logged in using the webUI
    When the user shares folder "simple-folder" with user "User One" using the webUI
    And the user sets the sharing permissions of user "User One" for "simple-folder" using the webUI to
      | share | no |
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then the option to rename file "lorem.txt" should be available on the webUI
    And it should not be possible to share file "lorem.txt" using the webUI
    And the option to delete file "lorem.txt" should be available on the webUI
    And the option to upload file should be available on the webUI
    When the user uploads file "textfile.txt" using the webUI
    Then as "user1" file "simple-folder/textfile.txt" should exist
    And file "textfile.txt" should be listed on the webUI
    And the content of "textfile.txt" should be the same as the local "textfile.txt"
    And it should not be possible to share file "textfile.txt" using the webUI

  @issue-35787
  Scenario: share a skeleton file after changing its content to a user before the user has logged in
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user2" has logged in using the webUI
    And user "user2" has uploaded file with content "edited original content" to "/lorem.txt"
    When the user shares file "lorem.txt" with user "User One" using the webUI
    Then the content of file "lorem.txt" for user "user2" should be "edited original content"
    When the user re-logs in as "user1" using the webUI
    Then the content of "lorem.txt" should be the same as the original "lorem.txt"
#   And the content of file "lorem.txt" for user "user1" should be "edited original content"

  @skipOnOcV10.3
  Scenario: Create share when admin disables delete in share permissions
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
      | user3    |
    And user "user2" has created folder "simple-folder"
    And user "user2" has uploaded file "filesForUpload/lorem.txt" to "simple-folder/lorem.txt"
    And the administrator has browsed to the admin sharing settings page
    When the administrator disables permission delete for default user and group share using the webUI
    And the user re-logs in as "user2" using the webUI
    And the user shares folder "simple-folder" with user "User One" using the webUI
    Then the following permissions are seen for "simple-folder" in the sharing dialog for user "User One"
      | change | yes |
      | create | yes |
      | delete | no  |
      | share  | yes |
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then the option to rename file "lorem.txt" should be available on the webUI
    And the option to delete file "lorem.txt" should not be available on the webUI
    And the option to upload file should be available on the webUI
    When the user shares file "lorem.txt" with user "User Three" using the webUI
    Then as "user3" file "lorem.txt" should exist

  @skipOnOcV10.3
  Scenario: Create share when admin disables change in share permissions
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
      | user3    |
    And user "user2" has created folder "simple-folder"
    And user "user2" has uploaded file "filesForUpload/lorem.txt" to "simple-folder/lorem.txt"
    And the administrator has browsed to the admin sharing settings page
    When the administrator disables permission change for default user and group share using the webUI
    And the user re-logs in as "user2" using the webUI
    And the user shares folder "simple-folder" with user "User One" using the webUI
    Then the following permissions are seen for "simple-folder" in the sharing dialog for user "User One"
      | change | no  |
      | create | yes |
      | delete | yes |
      | share  | yes |
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then the option to rename file "lorem.txt" should not be available on the webUI
    And the option to upload file should be available on the webUI
    When the user shares file "lorem.txt" with user "User Three" using the webUI
    Then as "user3" file "lorem.txt" should exist
    And the option to delete file "lorem.txt" should be available on the webUI

  @skipOnOcV10.3
  Scenario: Create share when admin disables create and share in share permissions
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user2" has created folder "simple-folder"
    And user "user2" has uploaded file "filesForUpload/lorem.txt" to "simple-folder/lorem.txt"
    And the administrator has browsed to the admin sharing settings page
    When the administrator disables permission create for default user and group share using the webUI
    And the administrator disables permission share for default user and group share using the webUI
    And the user re-logs in as "user2" using the webUI
    And the user shares folder "simple-folder" with user "User One" using the webUI
    Then the following permissions are seen for "simple-folder" in the sharing dialog for user "User One"
      | change | yes |
      | create | no  |
      | delete | yes |
      | share  | no  |
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then it should not be possible to share file "lorem.txt" using the webUI
    And the option to upload file should not be available on the webUI
    And the option to rename file "lorem.txt" should be available on the webUI
    And it should be possible to delete file "lorem.txt" using the webUI

  @skipOnOcV10.3
  Scenario: Create share when admin disables delete in share permissions but then user enables the permission
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user2" has created folder "simple-folder"
    And user "user2" has uploaded file "filesForUpload/lorem.txt" to "simple-folder/lorem.txt"
    And the administrator has browsed to the admin sharing settings page
    When the administrator disables permission delete for default user and group share using the webUI
    And the user re-logs in as "user2" using the webUI
    And the user shares folder "simple-folder" with user "User One" using the webUI
    And the user sets the sharing permissions of user "User One" for "simple-folder" using the webUI to
      | delete | yes |
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then the option to rename file "lorem.txt" should be available on the webUI
    And the option to upload file should be available on the webUI
    And it should not be possible to share file "lorem.txt" using the webUI
    And the option to delete file "lorem.txt" should be available on the webUI

  @skipOnOcV10.3
  Scenario: Create share when admin disables multiple default share permissions but then user enables a disabled permission
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
      | user3    |
    And user "user2" has created folder "simple-folder"
    And user "user2" has uploaded file "filesForUpload/lorem.txt" to "simple-folder/lorem.txt"
    And the administrator has browsed to the admin sharing settings page
    When the administrator disables permission delete for default user and group share using the webUI
    And the administrator disables permission share for default user and group share using the webUI
    And the user re-logs in as "user2" using the webUI
    And the user shares folder "simple-folder" with user "User One" using the webUI
    And the user sets the sharing permissions of user "User One" for "simple-folder" using the webUI to
      | share | yes |
    And the user re-logs in as "user1" using the webUI
    And the user opens folder "simple-folder" using the webUI
    Then the option to rename file "lorem.txt" should be available on the webUI
    And the option to upload file should be available on the webUI
    And the option to delete file "lorem.txt" should not be available on the webUI
    When the user shares file "lorem.txt" with user "User Three" using the webUI
    Then as "user3" file "lorem.txt" should exist

  @mailhog @skipOnOcV10.3
  Scenario: user without email should be able to send notification by email when allow share mail notification has been enabled
    Given parameter "shareapi_allow_mail_notification" of app "core" has been set to "yes"
    And these users have been created without skeleton files:
      | username | password |
      | user0    | 1234     |
    And user "user1" has been created with default attributes and without skeleton files
    And user "user0" has created folder "/simple-folder"
    And user "user0" has logged in using the webUI
    And user "user0" has shared folder "simple-folder" with user "user1"
    And the user has opened the share dialog for folder "simple-folder"
    When the user sends the share notification by email using the webUI
    Then a notification should be displayed on the webUI with the text "Email notification was sent!"
    And the email address "user1@example.org" should have received an email with the body containing
      """
      just letting you know that user0 shared simple-folder with you.
      """

  @skipOnOcV10.3
  Scenario: sharing indicator of items inside a shared folder
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user1" has logged in using the webUI
    When the user opens folder "simple-folder" using the webUI
    Then the following resources should have share indicators on the webUI
      | simple-empty-folder |
      | lorem.txt           |

  @skipOnOcV10.3
  Scenario: sharing indicator of items inside a shared folder two levels down
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user1" has created folder "/simple-folder/simple-empty-folder/new-folder"
    And user "user1" has uploaded file "filesForUpload/lorem.txt" to "/simple-folder/simple-empty-folder/lorem.txt"
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user1" has logged in using the webUI
    When the user opens folder "simple-folder" using the webUI
    And the user opens folder "simple-empty-folder" using the webUI
    Then the following resources should have share indicators on the webUI
      | new-folder |
      | lorem.txt  |

  @skipOnOcV10.3
  Scenario: sharing indicator of items inside a re-shared folder
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user1    |
    And these users have been created without skeleton files:
      | username |
      | user2    |
      | user3    |
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has shared folder "simple-folder" with user "user3"
    And user "user2" has logged in using the webUI
    When the user opens folder "simple-folder" using the webUI
    Then the following resources should have share indicators on the webUI
      | simple-empty-folder |
      | lorem.txt           |

  @skipOnOcV10.3
  Scenario: no sharing indicator of items inside a not shared folder
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user1    |
    And user "user1" has logged in using the webUI
    When the user opens folder "simple-folder" using the webUI
    Then the following resources should not have share indicators on the webUI
      | simple-empty-folder |
      | lorem.txt           |

  @skipOnOcV10.3
  Scenario: sharing details of items inside a shared folder
    Given these users have been created without skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user1" has created folder "/simple-folder"
    And user "user1" has created folder "/simple-folder/simple-empty-folder"
    And user "user1" has uploaded file "filesForUpload/lorem.txt" to "/simple-folder/lorem.txt"
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user1" has logged in using the webUI
    And the user has opened folder "simple-folder" using the webUI
    When the user opens the sharing tab from the file action menu of folder "simple-empty-folder" using the webUI
    Then user "user2" should be listed as share receiver via "simple-folder" on the webUI
    When the user opens the sharing tab from the file action menu of file "lorem.txt" using the webUI
    Then user "user2" should be listed as share receiver via "simple-folder" on the webUI

  @skipOnOcV10.3
  Scenario: sharing details of items inside a re-shared folder
    Given these users have been created without skeleton files:
      | username |
      | user1    |
      | user2    |
      | user3    |
    And user "user1" has created folder "/simple-folder"
    And user "user1" has created folder "/simple-folder/simple-empty-folder"
    And user "user1" has uploaded file "filesForUpload/lorem.txt" to "/simple-folder/lorem.txt"
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user2" has shared folder "simple-folder" with user "user3"
    And user "user2" has logged in using the webUI
    And the user has opened folder "simple-folder" using the webUI
    When the user opens the sharing tab from the file action menu of folder "simple-empty-folder" using the webUI
    Then user "user3" should be listed as share receiver via "simple-folder" on the webUI
    When the user opens the sharing tab from the file action menu of file "lorem.txt" using the webUI
    Then user "user3" should be listed as share receiver via "simple-folder" on the webUI

  @skipOnOcV10.3
  Scenario: sharing indicator for file uploaded inside a shared folder
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user1" has shared folder "/simple-empty-folder" with user "user2"
    And user "user1" has logged in using the webUI
    When the user opens folder "simple-empty-folder" using the webUI
    And the user uploads file "new-lorem.txt" using the webUI
    Then the following resources should have share indicators on the webUI
      | new-lorem.txt |

  @skipOnOcV10.3
  Scenario: sharing indicator for folder created inside a shared folder
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user1    |
      | user2    |
    And user "user1" has shared folder "/simple-empty-folder" with user "user2"
    And user "user1" has logged in using the webUI
    When the user opens folder "simple-empty-folder" using the webUI
    And the user creates a folder with the name "sub-folder" using the webUI
    Then the following resources should have share indicators on the webUI
      | sub-folder |

  @skipOnOcV10.3
  Scenario: sharing details of items inside a shared folder shared with multiple users
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
      | user2    |
      | user3    |
    And user "user1" has created folder "/simple-folder"
    And user "user1" has created folder "/simple-folder/sub-folder"
    And user "user1" has uploaded file "filesForUpload/lorem.txt" to "/simple-folder/sub-folder/lorem.txt"
    And user "user1" has shared folder "simple-folder" with user "user2"
    And user "user1" has shared folder "/simple-folder/sub-folder" with user "user3"
    And user "user1" has logged in using the webUI
    And the user has opened folder "simple-folder/sub-folder" using the webUI
    When the user opens the sharing tab from the file action menu of file "lorem.txt" using the webUI
    Then user "User Two" should be listed as share receiver via "simple-folder" on the webUI
    And user "User Three" should be listed as share receiver via "sub-folder" on the webUI

