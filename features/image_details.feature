Feature: search for movies by director

  As a user
  I want to view the details of an image
  So that I can see its associated information

Background: images in database
  Given the following images exist:
    | tag         | report    | run_time_object_id  |
    | image 1     | None      | 1                   |
    | image 2     | None      | 1                   |

Scenario: Viewing image details
  Given I am logged in
  When I go to the details page for "image 1"
  Then I should see the title "image 1"
  Then I should see the report button "View GRC Report"
  When I click "Go back" button
  Then I should be on the images page