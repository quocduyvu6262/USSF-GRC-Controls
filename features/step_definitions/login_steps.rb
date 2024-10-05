Given("I am on the index page") do
  visit root_path
end

When("I click on the {string} button") do |button|
  click_link_or_button button
end

When("I authorize the application on Google's consent screen") do
  mock_auth_hash(valid: true)
  visit '/auth/google_oauth2/callback'
end

Then("I should be redirected to the user page") do
  expect(page).to have_content("Name: John Doe")
end

When("I authorize the application with invalid credentials") do
  mock_auth_hash(valid: false)
  visit '/auth/google_oauth2/callback'
end

Then("I should be redirected to the index page") do
  visit root_path
end

Given("I have successfully logged in") do
  visit root_path
  click_on "Login with Google"
  mock_auth_hash(valid: true)
  visit '/auth/google_oauth2/callback'
end

When("I visit the index page") do
  visit root_path
end
