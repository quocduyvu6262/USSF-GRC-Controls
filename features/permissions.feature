Feature: Share Runtime Objects with Users

  Scenario: Owner shares a runtime object with other users
    Given I have successfully logged in
    And I am the owner of an object
    And user "Shared User" exists
    When I visit the runtime object page
    When I click on the "Access" button
    And I check the "view" checkbox for "Shared User"
    And I submit the share form
    Then "Shared User" should have permission to access the runtime object
    And I should be redirected to the runtime object page
  
  Scenario: Shared user views a runtime object
    Given I have successfully logged in
    And I am shared access to a runtime object
    When I visit the runtime object page
    Then I should not see the "Access" button