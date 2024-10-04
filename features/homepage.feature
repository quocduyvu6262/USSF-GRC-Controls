Feature: Playing around with the home page

  Background: 
    Given I have successfully logged in

  Scenario: Viewing user details in a modal
    When I click on the profile button
    Then I should see the modal with my logged in details
    And the modal should display my name
    And the modal should display my email

  Scenario: Navigating to the image page
    Given I have images displayed on my home page
    When I click on a particular image
    Then I should be taken to the image page
    And I should see the image details

  Scenario: Navigating to the create new page
    When I click on the "Create New" button
    Then I should be taken to the new page
    And I should see the form to create a new item
