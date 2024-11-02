Feature: Pagination

  As a user
  I want to view 7 tags per page only
  So that I do not need to scroll and instead click on the next page

  Scenario: Go to next page for tags
    Given the following tags exist:
      | tag         | report    | run_time_object_id  |
      | tag 1     | None      | 1                   |
      | tag 2     | None      | 1                   |
      | tag 3     | None      | 1                   |
      | tag 4     | None      | 1                   |
      | tag 5     | None      | 1                   |
      | tag 6     | None      | 1                   |
      | tag 7     | None      | 1                   |
      | tag 8     | None      | 1                   |
      | tag 9     | None      | 1                   |
      | tag 10    | None      | 1                   |
      | tag 11    | None      | 1                   |
      | tag 12    | None      | 1                   |
      | tag 13    | None      | 1                   |
      | tag 14    | None      | 1                   |
      | tag 15    | None      | 1                   |
      | tag 16    | None      | 1                   |
      | tag 17    | None      | 1                   |
      | tag 18    | None      | 1                   |
      | tag 19    | None      | 1                   |
    Given I have successfully logged in
    When I go to the details page for image with id 1
    Then I should see next and previous arrow when there are more than 1 page
    Then I should see 7 tags
    When I click on next page
    Then I should see 7 tags
    When I click on next page
    Then I should see 5 tags

  Scenario: View tags when there are fewer than 7 tags
    Given the following tags exist:
      | tag         | report    | run_time_object_id  |
      | tag 1     | None      | 1                   |
      | tag 2     | None      | 1                   |
      | tag 3     | None      | 1                   |
      | tag 4     | None      | 1                   |
      | tag 5     | None      | 1                   |
    And I have successfully logged in
    When I go to the details page for image with id 1
    Then I should not see pagination controls
    Then I should see 5 tags
    And I add 3 more tags
    And I refresh the page
    Then I should see next and previous arrow when there are more than 1 page
    Then I click on next page
    Then I should see 1 tags