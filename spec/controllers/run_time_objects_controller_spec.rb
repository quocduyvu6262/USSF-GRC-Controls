# spec/controllers/run_time_objects_controller_spec.rb
require 'rails_helper'

RSpec.describe RunTimeObjectsController, type: :controller do
  let(:user) { User.create(email: "test@example.com", first_name: "Test", last_name: "User") }
  let(:run_time_object) { RunTimeObject.create(name: "Sample Object", description: "A sample runtime object", user: user) }

  before do
    session[:user_id] = user.id
  end

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns @run_time_objects" do
      get :index
      expect(assigns(:run_time_objects)).to include(run_time_object)
    end
  end

  describe "GET #show" do
    it "redirects to the images path" do
      get :show, params: { id: run_time_object.id }
      expect(response).to redirect_to(run_time_object_images_path(run_time_object))
    end
  end

  describe "GET #new" do
    it "assigns a new RunTimeObject to @run_time_object" do
      get :new
      expect(assigns(:run_time_object)).to be_a_new(RunTimeObject)
    end

    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new RunTimeObject" do
        expect {
          post :create, params: { run_time_object: { name: "New Object", description: "New Description" } }
        }.to change(RunTimeObject, :count).by(1)
      end

      it "redirects to the new RunTimeObject" do
        post :create, params: { run_time_object: { name: "New Object", description: "New Description" } }
        expect(response).to redirect_to(RunTimeObject.last)
      end
    end

    context "with invalid parameters" do
      it "does not create a new RunTimeObject" do
        expect {
          post :create, params: { run_time_object: { name: "", description: "" } }
        }.not_to change(RunTimeObject, :count)
      end

      it "renders the new template" do
        post :create, params: { run_time_object: { name: "", description: "" } }
        expect(response).to render_template(:new)
      end
    end
  end
end
