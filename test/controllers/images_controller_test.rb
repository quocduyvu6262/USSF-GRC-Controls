require "test_helper"

# This is image controller
class ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @image = images(:one)
  end

  test "should get index" do
    get images_url
    assert_response :success
  end

  test "should get new" do
    get new_image_url
    assert_response :success
  end

  test "should show image" do
    get image_url(@image)
    assert_response :success
  end

  test "should get edit" do
    get edit_image_url(@image)
    assert_response :success
  end

  test "should update image" do
    patch image_url(@image), params: { image: { created_at: @image.created_at, report: @image.report, run_time_object_id: @image.run_time_object_id, tag: @image.tag, updated_at: @image.updated_at } }
    assert_redirected_to image_url(@image)
  end

  test "should destroy image" do
    assert_difference("Image.count", -1) do
      delete image_url(@image)
    end

    assert_redirected_to images_url
  end

  test "should rescan image and redirect to show" do
    post rescan_image_url(@image)
    @image.reloa
    assert_redirected_to image_url(@image)
    assert_not_nil @image.report# assert_equal 'expected_report_value', @image.report # You can add an assertion to check the contents if needed
  end
end
