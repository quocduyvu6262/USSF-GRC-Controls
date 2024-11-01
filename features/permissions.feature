Feature: Share Runtime Objects with Users

  Scenario: Owner shares a runtime object with other users
    Given I have successfully logged in
    Given user "Owner User" exists
    And user "Shared User" exists
    And "Owner User" is the owner of the object
    When I visit the share page for the runtime object
    When I click on the "Access" button
    And I check the checkbox for "Shared User"
    And I submit the share form
    Then "Shared User" should have permission to access the runtime object
    And I should be redirected to the runtime object page
