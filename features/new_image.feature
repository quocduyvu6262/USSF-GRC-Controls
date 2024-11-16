Feature: Create a new image

  As a user
  I want to create a new image
  So that I can see its vulnerability information

  Background: images in database
    Given I have successfully logged in
    Given the following tags exist:
      | tag             | Description    |

  Scenario: Create a new image
    When I go to new image page
    Then I should see the title "New Container Image"
    When I fill in "Name" with "alpine"
    When I fill in "Description" with "test"
    And I click "Create" button
    Then I should be on the image details page with title "alpine"