Given("I am on the index page") do
  visit root_path
end

When("I click on the {string} button") do |button|
  click_button button
end

When("I authorize the application on Google's consent screen") do
  visit '/auth/google_oauth2/callback'
end

Then("I am on the home page") do
  visit users_show_path
end
