Feature: Share Runtime Objects with Users

  Scenario: Owner shares a runtime object (view permission) with other users
    Given I have successfully logged in
    And I am the owner of an object
    And user "Shared User" exists
    When I visit the runtime object page
    When I click on the "Access" button
    And I check the "view" checkbox for "Shared User"
    And I submit the share form
    Then "Shared User" should have permission to access the runtime object
    And I should be redirected to the runtime object page
  
  Scenario: Shared user with view permission views a runtime object
    Given I have successfully logged in
    And I am shared access with "view" permission to a runtime object
    When I visit the runtime object page
    Then I should not see the "Access" button
    And I should not see the "Edit" button
    And I should not see the "Delete" button
    And I cannot access edit button in runtime object page
    And I cannot access delete button in runtime object page
    Given owner has following tags:
      | tag             | report    |
      | alpine          | ""      |
      | hello-world     | ""      |
    Then I visit image "alpine"
    Then I should be on the image details page with title "alpine"
    And I should not see the "Edit" button
    And I should not see the "Delete" button
    And I cannot access edit button in image page
    And I cannot access delete button in image page

  Scenario: Owner shares a runtime object (edit permission) with other users
    Given I have successfully logged in
    And I am the owner of an object
    And user "Shared User" exists
    When I visit the runtime object page
    When I click on the "Access" button
    And I check the "edit" checkbox for "Shared User"
    And I submit the share form
    Then "Shared User" should have permission to access the runtime object
    And I should be redirected to the runtime object page

  Scenario: Shared user with edit permission views a runtime object
    Given I have successfully logged in
    And I am shared access with "edit" permission to a runtime object
    When I visit the runtime object page
    Then I should not see the "Access" button
    And I should see the "Edit" button
    And I should see the "New Tag" button
    And I can access edit button in runtime object page
    And I can access new tag button in runtime object page
    Given owner has following tags:
      | tag             | report    |
      | alpine          | ""      |
      | hello-world     | ""      |
    Then I visit image "alpine"
    Then I should be on the image details page with title "alpine"
    And I should see the "Edit" button
    And I should see the "Delete" button
    And I can access edit button in image page
    And I can access delete button in image page

  Scenario: Unauthorized user tries to access a shared runtime object
    Given I have successfully logged in
    Given I am not shared access to a runtime object
    And I cannot visit the runtime object page
    And I cannot share the runtime object with other users
