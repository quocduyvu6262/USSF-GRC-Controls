Feature: Viewing image

  As a user
  I want to view the details of an image
  So that I can see its associated information

Background: images in database
  Given the following tags exist:
    | tag         | report    | run_time_object_id  |
    | image 1     | None      | 1                   |
    | image 2     | None      | 1                   |

Scenario: Viewing tag details
  Given I have successfully logged in
  When I go to the details page for tag "image 1"
  Then I should see the title "image 1"
  When I click "Go back" button
  Then I should be on the images page


Scenario: Edit image tag
  Given I have successfully logged in
  When I go to the details page for tag "image 1"
  Then I should see the title "image 1"
  When I click "Edit" button
  When I fill in "Tag URL" with "alpine:latest"
  When I click "Update Image" button
  Then I should see the title "alpine"

Scenario: Delete image tag
  Given I have successfully logged in
  When I go to the details page for tag "image 1"
  Then I should see the title "image 1"
  When I click "Delete" button
  Then I should see the message "Image was successfully deleted"

