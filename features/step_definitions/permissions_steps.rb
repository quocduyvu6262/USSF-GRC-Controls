Given("user {string} exists") do |full_name|
  first_name, last_name = full_name.split(" ")
  User.find_or_create_by(first_name: first_name, last_name: last_name) do |user|
    user.email = "#{first_name.downcase}@example.com"
  end
end

Given("{string} is the owner of the object") do |owner_name|
  first_name, last_name = owner_name.split(" ")
  @owner_user = User.find_by(first_name: first_name, last_name: last_name)
  @run_time_object = RunTimeObject.create(name: "Test Object", user: @owner_user)
end

When("I visit the share page for the runtime object") do
  visit run_time_object_images_path(@run_time_object)
end

When("I check the checkbox for {string}") do |user_full_name|
  first_name, last_name = user_full_name.split(" ")
  user = User.find_by(first_name: first_name, last_name: last_name)
  check("user_ids[]", option: user.id)
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
