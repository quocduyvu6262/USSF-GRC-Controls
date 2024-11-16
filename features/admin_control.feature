Feature: Manage Users

  Background: 
    Given I have successfully logged in
    Given I am the admin
    And user "Regular1 User" exists
    And user "Regular2 User" exists
    And I visit the "Manage Users" page

  Scenario: Admin views all users
    Then I should see "regular1@example.com" in the user table
    And I should see "regular2@example.com" in the user table

  Scenario: Admin updates a user's admin status
    Given I visit the "Manage Users" page
    When I checked the "Admin" checkbox for "regular1@example.com"
    And I click on Update button
    Then "regular1@example.com" should be an admin

  Scenario: Admin blocks a user
    Given I visit the "Manage Users" page
    When I checked the "Block" checkbox for "regular2@example.com"
    And I click on Update button
    Then "regular2@example.com" should be blocked

  Scenario: Regular user tries to access the Manage Users page
    Given I am logged in as a regular user
    When I visit the "Manage Users" page
    Then I should be redirected to the root path with an alert "You are not authorized to access this page"


 
  