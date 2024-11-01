# spec/controllers/run_time_objects_controller_spec.rb
require 'rails_helper'

RSpec.describe RunTimeObjectsController, type: :controller do
  let(:user) { User.create(email: "test@example.com", first_name: "Test", last_name: "User") }
  let(:user1) { User.create(email: "dummy@example.com", first_name: "Dummy", last_name: "User") }
  let(:user2) { User.create(email: "random@example.com", first_name: "Random", last_name: "User") }
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

  describe "GET #share" do
    it "assigns the correct run_time_object" do
      get :share, params: { id: run_time_object.id }
      expect(assigns(:run_time_object)).to eq(run_time_object)
    end

    it "assigns @users excluding the owner" do
      get :share, params: { id: run_time_object.id }
      expect(assigns(:users)).to match_array([ user1, user2 ])
      expect(assigns(:users)).not_to include(user)
    end
  end

  describe "POST #share_with_users" do
    context "when updating permissions" do
      it "removes permissions for unselected users" do
        post :share_with_users, params: { id: run_time_object.id, user_ids: [ user2.id ] }
        expect(run_time_object.run_time_objects_permissions.exists?(user_id: user1.id)).to be_falsey
      end

      it "adds permissions for selected users" do
        post :share_with_users, params: { id: run_time_object.id, user_ids: [ user1.id, user2.id ] }
        expect(run_time_object.run_time_objects_permissions.exists?(user_id: user2.id)).to be_truthy
      end
    end

    it "redirects to the run_time_object show page" do
      post :share_with_users, params: { id: run_time_object.id, user_ids: [ user1.id, user2.id ] }
      expect(response).to redirect_to(run_time_object)
    end
  end

  describe "DELETE #destroy" do
    context "when user owns the runtime object" do

      it "sets a success flash message" do
        delete :destroy, params: { id: run_time_object.id }
        expect(flash[:success]).to eq("Runtime object was successfully deleted.")
      end

      it "redirects to the index page" do
        delete :destroy, params: { id: run_time_object.id }
        expect(response).to redirect_to(run_time_objects_path)
      end

      context "when deletion fails" do
        before do
          allow_any_instance_of(RunTimeObject).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed.new("Error message"))
        end

        it "sets an error flash message" do
          delete :destroy, params: { id: run_time_object.id }
          expect(flash[:error]).to include("There was an error deleting the runtime object")
        end

        it "redirects to the runtime object page" do
          delete :destroy, params: { id: run_time_object.id }
          expect(response).to redirect_to(run_time_object)
        end
      end
    end

    context "when user doesn't own the runtime object" do
      before do
        sign_in other_user
      end

    end
  end

  describe "GET #edit" do
    it "assigns the requested run_time_object to @run_time_object" do
      get :edit, params: { id: run_time_object.id }
      expect(assigns(:run_time_object)).to eq(run_time_object)
    end
  end

  describe "PATCH #update" do
    context "when user owns the runtime object" do
      let(:valid_attributes) { { description: "Updated description" } }
      let(:invalid_attributes) { { description: "" } }

      context "with valid params" do
        it "updates the runtime object" do
          patch :update, params: { id: run_time_object.id, run_time_object: valid_attributes }
          run_time_object.reload
          expect(run_time_object.description).to eq("Updated description")
        end

        it "sets a success flash message" do
          patch :update, params: { id: run_time_object.id, run_time_object: valid_attributes }
          expect(flash[:success]).to eq("Runtime object was successfully updated.")
        end

        it "redirects to the runtime object" do
          patch :update, params: { id: run_time_object.id, run_time_object: valid_attributes }
          expect(response).to redirect_to(run_time_object)
        end
      end
    end

    context "when user doesn't own the runtime object" do
      before do
        sign_in other_user
      end

    end
  end
end
