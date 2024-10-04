Feature: Playing around with the home page

  Background: 
    Given I have successfully logged in

  Scenario: Viewing user details in a modal
    When I click on the profile button on the homepage
    Then I should see the modal with my logged in details
    And the modal should display my name
    And the modal should display my email

