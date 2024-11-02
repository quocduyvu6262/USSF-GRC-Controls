Feature: Pagination

  As a user
  I want to view 7 images per page only
  So that I do not need to scroll and instead click on the next page

  Scenario: Go to next page
    Given I have successfully logged in
    Given the following tags exist:
      | tag         | report    | run_time_object_id  |
      | image 1     | None      | 1                   |
      | image 2     | None      | 1                   |
      | image 3     | None      | 1                   |
      | image 4     | None      | 1                   |
      | image 5     | None      | 1                   |
      | image 6     | None      | 1                   |
      | image 7     | None      | 1                   |
      | image 8     | None      | 1                   |
      | image 9     | None      | 1                   |
      | image 10    | None      | 1                   |
      | image 11    | None      | 1                   |
      | image 12    | None      | 1                   |
      | image 13    | None      | 1                   |
      | image 14    | None      | 1                   |
      | image 15    | None      | 1                   |
      | image 16    | None      | 1                   |
      | image 17    | None      | 1                   |
      | image 18    | None      | 1                   |
      | image 19    | None      | 1                   |
    When I go to the details page for image with id 1
    Then I should see next and previous arrow when there are more than 1 page
    Then I should see 7 images
    When I click on next page
    Then I should see 7 images
    When I click on next page
    Then I should see 5 images

  Scenario: View images when there are fewer than 7 images
    Given I have successfully logged in
    Given the following tags exist:
      | tag         | report    | run_time_object_id  |
      | image 1     | None      | 1                   |
      | image 2     | None      | 1                   |
      | image 3     | None      | 1                   |
      | image 4     | None      | 1                   |
      | image 5     | None      | 1                   |
    When I go to the details page for image with id 1
    Then I should not see pagination controls
    Then I should see 5 images
    And I add 3 more images
    And I refresh the page
    Then I should see next and previous arrow when there are more than 1 page
    Then I click on next page
    Then I should see 1 images
