  # features/step_definitions/user_management_steps.rb

  Given("I am the admin") do
    @admin_user = User.find_by(email: "test@example.com")
    @admin_user.update(admin: true)
  end

  Given("I am logged in as a regular user") do
    @admin_user = User.find_by(email: "test@example.com")
  end

  Given("I visit the {string} page") do |page|
    visit manage_users_path
  end

  Then("I should see {string} in the user table") do |email|
    expect(page).to have_content(email)
  end


  When("I checked the {string} checkbox for {string}") do |checkbox, user_email|
    user = User.find_by(email: user_email)
    if checkbox == 'Admin'
        check("admin_user_ids[]", option: user.id)
    end
    if checkbox == 'Block'
        check("block_user_ids[]", option: user.id)
    end
  end

  Then("I click on Update button") do
    click_button "Update"
  end

  Then("{string} should be an admin") do |user_email|
    user = User.find_by(email: user_email)
    expect(user.admin?).to be_truthy
  end

  Then("{string} should be blocked") do |user_email|
    user = User.find_by(email: user_email)
    expect(user.block?).to be_truthy
  end

  Then("I should be redirected to the root path with an alert {string}") do |alert|
    visit root_path
  end

  When("I click the \"Delete\" link for {string}") do |email|
    within("tr", text: email) do
      click_link "Delete"
    end
  end

  And("I confirm the deletion") do
    page.driver.browser.switch_to.alert.accept
  end

  Then("{string} should no longer be in the user list") do |email|
    expect(page).to have_no_content(email)
  end
