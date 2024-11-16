Feature: Viewing image

  As a user
  I want to view the details of an image
  So that I can see its associated information

Background: images in database
  Given I have successfully logged in
  Given the following tags exist:
    | tag         | report    | run_time_object_id  |
    | image 1     | ""      | 1                   |
    | image 2     | ""      | 1                   |

Scenario: Viewing image details
  When I go to the details page for tag "image 1"
  Then I should see the title "image 1"
  When I click "Go back" button
  Then I should be on the images page


Scenario: Edit image tag
  When I go to the details page for tag "image 1"
  Then I should see the title "image 1"
  When I click "Edit" button
  When I fill in "Tag URL" with "alpine"
  When I click "Update" button
  Then I should see the title "alpine"

Scenario: Delete image tag
  When I go to the details page for tag "image 1"
  Then I should see the title "image 1"
  When I click "Delete" button
  Then I should see the message "Tag was successfully deleted"

