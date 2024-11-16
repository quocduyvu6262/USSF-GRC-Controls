Given("I am the owner of an object") do
  @owner_user = User.find_by(email: "test@example.com")
  @run_time_object = RunTimeObject.create(name: "Test Object", user: @owner_user)
  @current_run_time_object = @run_time_object
end

Given("user {string} exists") do |full_name|
  first_name, last_name = full_name.split(" ")
  User.find_or_create_by(first_name: first_name, last_name: last_name) do |user|
    user.email = "#{first_name.downcase}@example.com"
  end
end

When("I visit the runtime object page") do
  visit run_time_object_images_path(@current_run_time_object)
end

When("I check the {string} checkbox for {string}") do |permission_type, user_full_name|
  first_name, last_name = user_full_name.split(" ")
  user = User.find_by(first_name: first_name, last_name: last_name)
  value =  permission_type == "view" ? "view" : "edit"
  choose("#{value}_permission_#{user.id}")
end

When("I submit the share form") do
  click_button "Share"
end

Then("{string} should have permission to access the runtime object") do |user_full_name|
  first_name, last_name = user_full_name.split(" ")
  user = User.find_by(first_name: first_name, last_name: last_name)
  expect(@run_time_object.run_time_objects_permissions.exists?(user_id: user.id)).to be true
end

Then("I should be redirected to the runtime object page") do
  visit run_time_object_path(@run_time_object)
end

Given("I am shared access with {string} permission to a runtime object") do |permission_type|
  @shared_user = User.find_by(email: "test@example.com")
  @owner_user = User.create(email: "owner@example.com", first_name: "owner", last_name: "user")
  @current_run_time_object = RunTimeObject.create(name: "Test Object", user: @owner_user)
  permission = "r"
  if permission_type == "view"
    permission = "r"
  elsif permission_type == "edit"
    permission = "e"
  end
  RunTimeObjectsPermission.create(run_time_object: @current_run_time_object, user_id: @shared_user.id, permission: permission)
end

Given("I am not shared access to a runtime object") do
  @shared_user = User.find_by(email: "test@example.com")
  @owner_user = User.create(email: "owner@example.com", first_name: "owner", last_name: "user")
  @current_run_time_object = RunTimeObject.create(name: "Test Object", user: @owner_user)
end

Given("owner has following tags:") do |table|
  @user = User.find_by(email: "test@example.com")
  table.hashes.each do |tag_data|
    Image.create!(
      tag: tag_data['tag'],
      report: tag_data['report'],
      run_time_object_id: @current_run_time_object.id # Use the stored run_time_object
    )
  end
end



Then("I should not see the {string} button") do |button_text|
  if button_text == "Delete"
    expect(page).not_to have_button(button_text)
  else
    expect(page).not_to have_link(button_text)
  end
end

Then("I should see the {string} button") do |button_text|
  case button_text
  when "Edit"
    expect(page).to have_selector('a i.fa-edit')
  when "Delete"
    expect(page).to have_selector('a i.fa-trash-alt')
  when "New Tag"
    expect(page).to have_selector('a i.fa-plus-circle')
  when "Access"
    expect(page).to have_selector('a i.fa-share-alt')
  else
    raise "No step defined for this button: #{button_text}"
  end
end


Then("I visit image {string}") do |image_name|
  image = Image.find_by(tag: image_name)
  visit run_time_object_image_path(image.run_time_object, image)
end

And("I cannot access edit button in runtime object page") do
  visit edit_run_time_object_path(@current_run_time_object)
  expect(page).to have_text("You are not authorized to edit this object.")
  expect(page).to have_current_path(run_time_objects_path)
end

And("I cannot access delete button in runtime object page") do
  page.driver.submit :delete, run_time_object_path(@current_run_time_object), {}
  visit run_time_objects_path
  expect(RunTimeObject.exists?(@current_run_time_object.id)).to be true
  expect(page).to have_current_path(run_time_objects_path)
end

And("I cannot access edit button in image page") do
  visit edit_run_time_object_image_path(@current_run_time_object, Image.first)
  expect(page).to have_text("You are not authorized to edit this data.")
  expect(page).to have_current_path(run_time_objects_path)
end

And("I cannot access delete button in image page") do
  @image = Image.first
  visit edit_run_time_object_image_path(@current_run_time_object, @image)
  page.driver.submit :delete, run_time_object_image_path(@current_run_time_object, @image), {}
  expect(Image.exists?(@image.id)).to be true
end

And("I can access edit button in runtime object page") do
  visit edit_run_time_object_path(@current_run_time_object)
  expect(page).to have_text("Edit")
  expect(page).to have_current_path(edit_run_time_object_path(@current_run_time_object))
end

And("I can access new tag button in runtime object page") do
  visit new_run_time_object_image_path(@current_run_time_object)
  expect(page).to have_text("New Tag")
  expect(page).to have_current_path(new_run_time_object_image_path(@current_run_time_object))
end

And("I can access edit button in image page") do
  visit edit_run_time_object_path(@current_run_time_object)
  expect(page).to have_text("Edit")
  expect(page).to have_current_path(edit_run_time_object_path(@current_run_time_object))
end

And("I can access delete button in image page") do
  @image = Image.first
  visit edit_run_time_object_image_path(@current_run_time_object, @image)
  page.driver.submit :delete, run_time_object_image_path(@current_run_time_object, @image), {}
  expect(Image.exists?(@image.id)).to be false
end

And("I cannot visit the runtime object page") do
  visit run_time_object_images_path(@current_run_time_object)
  expect(page).to have_text("You are not authorized to view this data.")
  expect(page).to have_current_path(run_time_objects_path)
end

And("I cannot share the runtime object with other users") do
  visit share_run_time_object_path(@current_run_time_object)
  expect(page).to have_text("You are not authorized to share this run time object.")
  expect(page).to have_current_path(run_time_objects_path)
end
