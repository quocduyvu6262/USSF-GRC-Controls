require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  let(:user) { User.create(email: "test@example.com", first_name: "Test", last_name: "User") }
  let(:run_time_object) { RunTimeObject.create(name: "Sample Object", description: "A sample runtime object", user: user) }

  before do
    session[:user_id] = user.id
    Image.destroy_all
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
  end
end
