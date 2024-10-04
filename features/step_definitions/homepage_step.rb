Given("I have successfully logged in on the homepage") do
    visit root_path
    click_on "Login with Google"
    mock_auth_hash(valid: true)  # Mocks a valid Google OAuth response
    visit '/auth/google_oauth2/callback'
end

When("I click on the profile button on the homepage") do
    find(".btn-profile").click  # Using the class 'btn-profile'
  end


Then('I should see the modal with my logged in details') do
    expect(page).to have_selector('.modal')  # Ensure the modal appears
end

Then('the modal should display my name') do
    expect(page).to have_content("John Doe")  # Update to the actual name being displayed
  end


Then('the modal should display my email') do
    user_email = "test@example.com"  # Replace with the email set in mock_auth_hash
    expect(page).to have_content(user_email)  # Check if the modal contains the user's email
end
