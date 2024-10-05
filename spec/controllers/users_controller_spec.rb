# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe "Users", type: :request do
  # Create a user to be used in the tests
  let!(:user) do
    User.create!(
      email: "testuser@gmail.com",
      first_name: "Test",
      last_name: "User",
      uid: "123456789",
      provider: "google_oauth2"
    )
  end

  # Create associated RunTimeObjects for the user
  let!(:rto1) { RunTimeObject.create!(name: "Object 1", description: "Description of Object 1", user_id: user.id) }
  let!(:rto2) { RunTimeObject.create!(name: "Object 2", description: "Description of Object 2", user_id: user.id) }

  # Create associated Images for the runtime objects
  let!(:image1) { Image.create!(tag: "Image 1", report: "Report for image 1", run_time_object_id: rto1.id) }
  let!(:image2) { Image.create!(tag: "Image 2", report: "Report for image 2", run_time_object_id: rto2.id) }  # Changed r2 to rto2

  # Simulate successful login using OmniAuth before each test
  before do
    get '/auth/google_oauth2/callback'  # Simulates the login by calling the OmniAuth callback
  end

  describe "GET /users/:id" do
    it "assigns @rto_list with the runtime objects for the user" do
      get user_path(user.id)  # Use the dynamically created user's ID
      expect(response).to be_successful  # Ensure the response is successful
      rto_list = RunTimeObject.where(user_id: user.id)  # Get RTOs for that user
      actual_rto_list = assigns(:rto_list)  # Get the value assigned by the controller
      expect(actual_rto_list).to match_array(rto_list)  # Check if both lists match
    end

    it "assigns @image_list with images from runtime objects for the user" do
      get user_path(user.id)  # Use the dynamically created user's ID
      rto_list = RunTimeObject.where(user_id: user.id)  # Get RTOs for that user
      image_list = Image.where(run_time_object_id: rto_list.pluck(:id))  # Fetch images

      actual_image_list = assigns(:image_list)  # Get the value assigned by the controller
      expect(actual_image_list).to match_array(image_list)  # Check if both lists match
    end

    it "returns a successful response" do
      get user_path(user.id)
      expect(response).to have_http_status(:success)  # Ensure the response is successful
    end
  end
end
