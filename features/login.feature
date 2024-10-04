Feature: Google SSO Login

  Scenario: Successful login with Google SSO
    Given I am on the index page
    When I click on the "Login with Google" button
    And I authorize the application on Google's consent screen
    Then I am on the home page