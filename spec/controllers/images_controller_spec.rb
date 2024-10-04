require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  let(:user) { User.create(email: "test@example.com", first_name: "Test", last_name: "User") }
  let(:run_time_object) { RunTimeObject.create(name: "Sample Object", description: "A sample runtime object", user: user) }

  before do
    session[:user_id] = user.id
    Image.destroy_all
  end

  describe "images index" do
    it "returns a successful response" do
      get :index, format: :json
      expect(response).to be_successful
    end
  end

  describe "creates" do
    it 'creates image with valid parameters' do
      post :create, params: { image: {
        tag: 'alpine',
        run_time_object_id: run_time_object.id
      } }
      expect(response).to redirect_to(Image.last)
      expect(flash[:notice]).to match('Image was successfully scanned')
    end

    it 'creates image with invalid parameters' do
      post :create, params: { image: {
        tag: '',
        run_time_object_id: ''
      } }
      expect(response).to redirect_to(new_image_path)
    end
  end

  describe "update" do
    it "updates image with valid parameters" do
      image = Image.create(tag: "alpine", run_time_object: run_time_object)
      put :update, params: { id: image.id, image: { tag: "ubuntu" } }
      image.reload
      expect(image.tag).to eq("ubuntu")
    end

    it "updates image with invalid parameters" do
      image = Image.create(tag: "alpine", run_time_object: run_time_object)
      put :update, params: { id: image.id, image: { tag: '', run_time_object_id: '' } }
      puts "Response status: #{response.status}"
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "destroy" do
    it "destroys the requested image" do
      image = Image.create(tag: "alpine", run_time_object: run_time_object)
      expect {
        delete :destroy, params: { id: image.to_param }
      }.to change(Image, :count).by(-1)
    end
  end
end
