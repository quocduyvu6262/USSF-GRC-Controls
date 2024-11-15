require "application_system_test_case"

class ImagesTest < ApplicationSystemTestCase
  setup do
    @image = images(:one)
  end

  test "visiting the index" do
    visit images_url
    assert_selector "h1", text: "Images"
  end

  test "should create image" do
    visit images_url
    click_on "New image"

    fill_in "Created at", with: @image.created_at
    fill_in "Report", with: @image.report
    fill_in "Run time object", with: @image.run_time_object_id
    fill_in "Tag", with: @image.tag
    fill_in "Updated at", with: @image.updated_at
    click_on "New Image"

    assert_text "Image was successfully created"
    click_on "Back"
  end

  test "should update Image" do
    visit image_url(@image)
    click_on "Edit this image", match: :first

    fill_in "Created at", with: @image.created_at
    fill_in "Report", with: @image.report
    fill_in "Run time object", with: @image.run_time_object_id
    fill_in "Tag", with: @image.tag
    fill_in "Updated at", with: @image.updated_at
    click_on "Update"

    assert_text "Image was successfully updated"
    click_on "Back"
  end

  test "should destroy Image" do
    visit image_url(@image)
    click_on "Destroy this image", match: :first

    assert_text "Image was successfully destroyed"
  end
end
