Given('the following images exist:') do |table|
  user = User.create!(email: 'quocduyvu6262@gmail.com', first_name: 'Test', last_name: 'User')
  RunTimeObject.create!([{ name: "Object 1", description: "This is a description of Object 1.", user_id: user.id }])
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

Then('I should see the title {string}') do |string|
  expect(page).to have_content(string)
end