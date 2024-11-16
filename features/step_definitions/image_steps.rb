Given('the following tags exist:') do |table|
  @user = User.find_by(email: "test@example.com")
  @run_time_object = RunTimeObject.create!(name: "Object 1", description: "This is a description of Object 1.", user_id: @user.id)

  table.hashes.each do |tag_data|
    Image.create!(
      tag: tag_data['tag'],
      report: tag_data['report'],
      run_time_object_id: @run_time_object.id # Use the stored run_time_object
    )
  end
end

Given('the following images exist:') do |table|
  user = User.create!(email: 'testuser@gmail.com', first_name: 'Test', last_name: 'User')

  table.hashes.each do |image_data|
    RunTimeObject.create!(
      name: image_data['Name'],
      user_id: user.id
    )
  end
end

When('I go to the details page for image with id {int}') do |int|
  rto = RunTimeObject.find_by(id: int)
  visit run_time_object_path(rto.id)
  end

When('I go to the details page for tag {string}') do |string|
  image = Image.find_by(tag: string)
  visit run_time_object_image_path(image.id, image.run_time_object.id)
end

When('I go to new tag page') do
  visit new_run_time_object_image_path(@run_time_object.id)
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

Then('I should be on the tag details page with title {string}') do |content|
  expect(page).to have_content(content)
end

Then('I should be on the images page') do
  visit root_path
end

Then('I should be on the image details page with title {string}') do |content|
  expect(page).to have_content(content)
end

When('I go to new image page') do
  visit new_run_time_object_path
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


Then('I should see the message {string}') do |message|
  expect(page).to have_content(message)
end


Then('I should be on the details page for {string}') do |image_tag|
  image = Image.find_by(tag: image_tag)
  expect(page).to have_current_path(image_path(image))
end

Given('I am on the tag details page for {string}') do |image_tag|
  image = Image.find_by(tag: image_tag)
  visit run_time_object_image_path(image.id, image.run_time_object.id)
end

When('I click the {string} button') do |button_name|
  click_button(button_name)
end
