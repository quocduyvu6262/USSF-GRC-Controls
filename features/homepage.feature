Feature: Playing around with the home page

  Background: 
    Given I have successfully logged in

  Scenario: User opens the dropdown menu
    When I click the dropdown button
    Then I should see my name "John"

  Scenario: User closes the dropdown menu
    Given I have opened the dropdown menu
    When I click the dropdown button again
    Then I should not see the dropdown menu

  Scenario: User clicks outside the dropdown menu
    Given I have opened the dropdown menu
    When I click outside the dropdown menu
    Then I should not see the dropdown menu