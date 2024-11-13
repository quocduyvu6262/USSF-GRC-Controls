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

Given("I am shared access to a runtime object") do
  @another_user = User.create(email: "dummy@example.com", first_name: "Dummy", last_name: "User")
  @owner_user = User.find_by(email: "test@example.com")
  @current_run_time_object = RunTimeObject.create(name: "Test Object", user: @another_user)
  RunTimeObjectsPermission.create(run_time_object: @shared_run_time_object, user_id: @owner_user.id, permission: "r")
end

Then("I should not see the {string} button") do |button_text|
  expect(page).not_to have_button(button_text)
end
