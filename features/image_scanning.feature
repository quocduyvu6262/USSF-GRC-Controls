Feature: Scanning Docker Images with Dynamic Input
  As a user
  I want to dynamically input a Docker image tag
  So that I can perform a Trivy scan and view the results

  Background:
    Given the following images exist:
      | tag                | report               | run_time_object_id |
      | python:3.4-alpine   | Trivy scan result... | 1                  |
    And I have successfully logged in

  Scenario: Scan an image with a valid tag
    Given I go to new image page
    When I fill in "Image Name" with "python"
    And I fill in "Image URL" with "python:3.4-alpine"
    And I fill in "Run Time Object" with "1"
    And I fill in "Description" with "test"
    And I click "Submit" button
    Then I should be on the image details page with title "python"
