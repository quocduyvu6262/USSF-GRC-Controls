Given("I am on the index page") do
  visit root_path
end

When("I click on the {string} button") do |button|
  click_link_or_button button
end

When("I authorize the application on Google's consent screen") do
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
                                                                     provider: 'google_oauth2',
                                                                     uid: '123456789',
                                                                     info: {
                                                                       email: 'test@example.com',
                                                                       first_name: 'John',
                                                                       last_name: 'Doe',
                                                                       name: 'John Doe'
                                                                     },
                                                                     credentials: {
                                                                       token: 'mock_token',
                                                                       refresh_token: 'mock_refresh_token',
                                                                       expires_at: Time.now + 1.week
                                                                     }
                                                                   })
  visit '/auth/google_oauth2/callback'
end

Then("I am on the user page") do
  puts page
  expect(page).to have_content("Name: John Doe")
end

When("I authorize the application with invalid credentials") do
  OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
  visit '/auth/google_oauth2/callback'
end

Then("I should be redirected to the home page") do
  visit root_path
end
