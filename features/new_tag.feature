Feature: Create a new tag

  As a user
  I want to create a new tag for an image
  So that I can see its vulnerability information

  Background: images in database
    Given I have successfully logged in
    Given the following tags exist:
      | tag             | report    | run_time_object_id  |
      | alpine          | None      | 1                   |
      | hello-world     | None      | 1                   |

  Scenario: Create a new tag
    When I go to the details page for image with id 1
    When I go to new tag page
    Then I should see the title "New Tag"
    When I fill in "Tag URL" with "centos:centos7.9.2009"
    And I click "Create" button
    Then I should be on the tag details page with title "centos"