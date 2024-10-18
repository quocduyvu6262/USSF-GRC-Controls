Given("I have successfully logged in on the homepage") do
    visit root_path
    click_on "Login with Google"
    mock_auth_hash(valid: true)  # Mocks a valid Google OAuth response
    visit '/auth/google_oauth2/callback'
end


When('I click the dropdown button') do
  find('#dropdownButton').click
end


Given('I have opened the dropdown menu') do
  step 'I click the dropdown button'
end

When('I click the dropdown button again') do
  find('#dropdownButton').click
end

Then('I should see my name {string}') do |name|
  expect(page.html).to have_content(name)
end


Then('I should not see the dropdown menu') do
  expect(page).to have_css('#dropdownMenu', visible: false)
end

When('I click outside the dropdown menu') do
  find('body').click # Simulates clicking outside
end
