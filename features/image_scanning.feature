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
    When I fill in "Image Name" with "python:3.4-alpine"
    And I select "Object 1" from the "Select Run Time Object"
    And I click "Submit" button
    Then I should be on the image details page with title "python:3.4-alpine"
