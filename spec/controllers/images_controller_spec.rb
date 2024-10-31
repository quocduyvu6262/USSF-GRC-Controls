require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  let(:user) { User.create(email: "test@example.com", first_name: "Test", last_name: "User") }
  let(:run_time_object) { RunTimeObject.create(name: "Sample Object", description: "A sample runtime object", user: user) }
  let(:image) { Image.create(tag: "alpine", run_time_object: run_time_object) }

  before do
    session[:user_id] = user.id
    RunTimeObject.destroy_all
    Image.destroy_all
  end

  describe "images index" do
    it "returns a successful response" do
      get :index, params: { run_time_object_id: run_time_object.id }
      expect(response).to be_successful
    end
  end

  describe "creates" do
    it 'creates image with valid parameters' do
      post :create, params: { run_time_object_id: run_time_object.id, image: {
        tag: 'alpine',
        run_time_object_id: run_time_object.id
      } }
      expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, Image.last))
    end

    it 'creates image with invalid parameters' do
      post :create, params: { run_time_object_id: run_time_object.id, image: {
        tag: '',
        run_time_object_id: ''
      } }
      expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, Image.last))
    end
  end

  describe "update" do
    it "updates image with valid parameters" do
      image = Image.create(tag: "alpine", run_time_object: run_time_object)
      put :update, params: { run_time_object_id: run_time_object.id, id: image.id, image: { tag: "ubuntu" } }
      image.reload
      expect(image.tag).to eq("ubuntu")
    end

    it "updates image with invalid parameters" do
      image = Image.create(tag: "alpine", run_time_object: run_time_object)
      put :update, params: { run_time_object_id: run_time_object.id, id: image.id, image: { tag: '', run_time_object_id: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "destroy" do
    it "destroys the requested image" do
      image = Image.create(tag: "alpine", run_time_object: run_time_object)
      expect {
        delete :destroy, params: { run_time_object_id: run_time_object.id, id: image.to_param }
      }.to change(Image, :count).by(-1)
    end
  end
  ######
  describe "create with dynamic image name" do
    it 'scans the image based on dynamic tag provided' do
      allow(controller).to receive(:`).and_return("Mock scan result")
      post :create, params: { run_time_object_id: run_time_object.id, image: { tag: 'python:3.4-alpine' } }
      expect(assigns(:image).report).to eq("Mock scan result")
    end

    it 'redirects to right page' do
      allow(controller).to receive(:`).and_return("Mock scan result")
      post :create, params: { run_time_object_id: run_time_object.id, image: { tag: 'python:3.4-alpine' } }
      expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, Image.last))
    end
  end

  describe "show" do
    it "displays the report for a scanned image" do
      image = Image.create(tag: "python:3.4-alpine", report: '{"Results":[{"Target":"ABC","Vulnerabilities":[{"VulnerabilityID": "CVE-2016-2781", "FixedVersion": "1.1.1"}]}]}', run_time_object: run_time_object)
      get :show, params: { run_time_object_id: run_time_object.id, id: image.id }
      expect(assigns(:vulnerability_summary)).to be_present
    end

    it "response is successful" do
      image = Image.create(tag: "python:3.4-alpine", report: '{"Results":[{"Target":"ABC","Vulnerabilities":[]}]}', run_time_object: run_time_object)
      get :show, params: { run_time_object_id: run_time_object.id, id: image.id }
      expect(response).to be_successful
    end
  end

  describe "create without running scan" do
    it 'creates image without running a scan' do
      allow(controller).to receive(:`).and_return(nil)  # No scan is performed
      post :create, params: { run_time_object_id: run_time_object.id, image: { tag: 'ubuntu:latest' } }
      expect(assigns(:image).report).to be_nil
    end

    it 'redirects to right page' do
      allow(controller).to receive(:`).and_return(nil)  # No scan is performed
      post :create, params: { run_time_object_id: run_time_object.id, image: { tag: 'ubuntu:latest' } }
      expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, Image.last))
    end
  end

  describe "new" do
    it "sets the correct user for new action" do
      get :new, params: { run_time_object_id: run_time_object.id }
      expect(assigns(:user)).to eq(user)
    end

    it "renders the new template" do
      get :new, params: { run_time_object_id: run_time_object.id }
      expect(response).to render_template(:new)
    end
  end

  describe "response formats" do
    it "returns HTML format for show" do
      image = Image.create(tag: "python:3.4-alpine", report: '{"Results":[{"Target":"ABC","Vulnerabilities":[]}]}', run_time_object: run_time_object)
      get :show, params: { run_time_object_id: run_time_object.id, id: image.id }, format: :html
      expect(response.content_type).to eq("text/html; charset=utf-8")
    end
  end

  describe "rescan" do
    let!(:image) { Image.create(tag: "alpine", run_time_object: run_time_object) }
  
    before do
      allow(controller).to receive(:current_user).and_return(user)
    end
  
    context 'when the scan is successful' do
      before do
        allow(controller).to receive(:`).and_return('{"Results":[]}') # Mocking the scan output
        post :rescan, params: { run_time_object_id: run_time_object.id, id: image.id }
      end
  
      it 'updates the image report' do
        image.reload
        expect(image.report).to eq('{"Results":[]}')
      end
  
      it 'redirects to the image show page' do
        expect(response).to redirect_to(run_time_object_image_path(run_time_object.id, image))
        expect(flash[:notice]).to eq("Rescan was successful.")
      end
    end
  
  end  
end
