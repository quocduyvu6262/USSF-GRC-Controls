Feature: Create a new image

  As a user
  I want to create a new image
  So that I can see its vulnerability information

  Background: images in database
    Given the following tags exist:
      | tag             | report    | run_time_object_id  |
      | alpine          | None      | 1                   |
      | hello-world     | None      | 1                   |

  Scenario: Create a new image
    Given I have successfully logged in
    When I go to new image page
    Then I should see the title "New Tag"
    When I fill in "Tag URL" with "alpine"
    And I click "Submit" button
    Then I should be on the image details page with title "alpine"