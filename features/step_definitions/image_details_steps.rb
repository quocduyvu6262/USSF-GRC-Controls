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

When('I go to the details page for {string}') do |string|
  image = Image.find_by(tag: string)
  visit tag_path(image.tag)
end

Then('I should see the title {string}') do |string|
  expect(page).to have_content(string)
end