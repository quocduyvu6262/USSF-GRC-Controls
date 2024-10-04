Feature: Google SSO Login

  Scenario: Failed login with Google SSO
    Given I am on the index page
    When I click on the "Login with Google" button
    And I authorize the application with invalid credentials
    Then I should be redirected to the home page

    
  Scenario: Successful login with Google SSO
    Given I am on the index page
    When I click on the "Login with Google" button
    And I authorize the application on Google's consent screen
    Then I am on the user page
  

  Scenario: User successfully logs in and then logs out
    Given I am on the index page
    When I click on the "Login with Google" button
    And I authorize the application on Google's consent screen
    Then I am on the user page
    When I click on the "Logout" button
    Then I should be redirected to the home page
  

  