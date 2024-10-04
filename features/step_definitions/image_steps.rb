Given('the following images exist:') do |table|
  user = User.create!(email: 'quocduyvu6262@gmail.com', first_name: 'Test', last_name: 'User')
  RunTimeObject.create!([ { name: "Object 1", description: "This is a description of Object 1.", user_id: user.id } ])
  table.hashes.each do |image_data|
    Image.create!(
      tag: image_data['tag'],
      report: image_data['report'],
      run_time_object_id: image_data['run_time_object_id']
    )
  end
end

Given('I am logged in') do
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

When('I go to the details page for {string}') do |string|
  image = Image.find_by(tag: string)
  visit image_path(image.id)
end

When('I go to new image page') do
  visit new_image_path
end

Then('I should see the title {string}') do |string|
  expect(page).to have_content(string)
end

Then('I should see the report button {string}') do |string|
  expect(page).to have_content(string)
end

When('I fill in {string} with {string}') do |string1, string2|
  fill_in string1, with: string2
end

When('I select {string} from the {string}') do |option, dropdown|
  select option, from: dropdown
end

When('I click {string} button') do |button_text|
  click_on button_text
end

Then('I should see {string}') do |arg|
  expect(page).to have_content(arg)
end

Then('I should be on the image details page with title {string}') do |content|
  expect(page).to have_content(content)
end

Then('I should be on the images page') do
  visit root_path
end

#########
When('I perform a Trivy scan on {string}') do |image_tag|
  @image = Image.create(tag: image_tag, run_time_object_id: 1)
  @image.report = `trivy image #{image_tag} 2>&1`  # Simulating the Trivy scan
  @image.save
end

Then('I should see the scan report for {string}') do |image_tag|
  image = Image.find_by(tag: image_tag)
  expect(page).to have_content(image.report)
end

Then('I should see an error message for invalid tag') do
  expect(page).to have_content("Trivy scan failed")
end

# Step to ensure the user sees the success message
Then('I should see the success message {string}') do |message|
  expect(page).to have_content(message)
end

# Step to ensure the user is redirected to the details page after a successful scan
Then('I should be on the details page for {string}') do |image_tag|
  image = Image.find_by(tag: image_tag)
  expect(page).to have_current_path(image_path(image))
end
