Feature: Google SSO Login

  Scenario: Failed login with Google SSO
    Given I am on the index page
    When I click on the "Login with Google" button
    And I authorize the application with invalid credentials
    Then I should be redirected to the index page

    
  Scenario: Successful login with Google SSO
    Given I am on the index page
    When I click on the "Login with Google" button
    And I authorize the application on Google's consent screen
    Then I should be redirected to the user page
  

  Scenario: User successfully logs in and then logs out
    Given I have successfully logged in
    When I click on logout
    Then I should be redirected to the index page
  
  Scenario: Logged-in user is redirected to their user page
    Given I have successfully logged in
    When I visit the index page
    Then I should be redirected to the user page


  