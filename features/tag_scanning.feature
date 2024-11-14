Feature: Scanning Docker Images with Dynamic Input
  As a user
  I want to dynamically input a Docker image tag
  So that I can perform a Trivy scan and view the results

  Background:
    Given I have successfully logged in
    Given the following tags exist:
      | tag                | report               | run_time_object_id |
      | python:3.4-alpine   | ""                  | 1                  |

  Scenario: Scan a image with a valid tag
    Given I go to new tag page
    And I fill in "Tag URL" with "python:3.4-alpine"
    And I click "Submit" button
    Then I should be on the image details page with title "python"

	Scenario: Rescan an existing image
		Given I am on the tag details page for "python:3.4-alpine"
    When I click the "Rescan" button
    Then I should be on the tag details page with title "python"