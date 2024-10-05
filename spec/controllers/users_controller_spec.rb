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


  let!(:rto1) { RunTimeObject.create!(name: "Object 1", description: "Description of Object 1", user_id: user.id) }
  let!(:rto2) { RunTimeObject.create!(name: "Object 2", description: "Description of Object 2", user_id: user.id) }

 
  let!(:image1) { Image.create!(tag: "Image 1", report: "Report for image 1", run_time_object_id: rto1.id) }
  let!(:image2) { Image.create!(tag: "Image 2", report: "Report for image 2", run_time_object_id: rto2.id) }  # Changed r2 to rto2


  before do
    get '/auth/google_oauth2/callback'  
  end

  describe "GET /users/:id" do
    it "assigns @rto_list with the runtime objects for the user" do
      get user_path(user.id) 
      expect(response).to be_successful  
      rto_list = RunTimeObject.where(user_id: user.id)  
      actual_rto_list = assigns(:rto_list)  
      expect(actual_rto_list).to match_array(rto_list)  
    end

    it "assigns @image_list with images from runtime objects for the user" do
      get user_path(user.id)  
      rto_list = RunTimeObject.where(user_id: user.id)  
      image_list = Image.where(run_time_object_id: rto_list.pluck(:id))  

      actual_image_list = assigns(:image_list) 
      expect(actual_image_list).to match_array(image_list) 
    end

    it "returns a successful response" do
      get user_path(user.id)
      expect(response).to have_http_status(:success)  
    end
  end
end
