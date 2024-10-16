Then("I should be on page {int}") do |page_number|
  expect(page).to have_current_path("/users/1?page=#{page_number}")
end

Then("I should see next and previous arrow when there are more than 1 page") do
  expect(page).to have_css('.pagy-nav', visible: true)
end

Then("I should see {int} images") do |num|
  expect(page).to have_css('.image-tile', count: num)
end

When("I click on next page") do
  if page.current_url.include?("?page=")
    current_page = page.current_url.split("=").last.to_i || 1
  else
    current_page = 1
  end
  puts "Current page: #{current_page}"
  next_page = current_page + 1
  visit "/users/1?page=#{next_page}"
end

Then("I should not see pagination controls") do
  expect(page).to_not have_css('.pagy-nav', visible: true)
end