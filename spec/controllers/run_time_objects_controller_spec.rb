require 'rails_helper'

RSpec.describe RunTimeObjectsController, type: :controller do
  
  let(:user) { User.create(email: "test@example.com", first_name: "Test", last_name: "User") }
  let(:another_user) { User.create(email: "dummy@example.com", first_name: "Dummy", last_name: "Person")  }
  let(:run_time_object) { RunTimeObject.create(name: "Sample Object", description: "A sample runtime object", user: user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET #share" do
    it "assigns the run_time_object, users, and permitted_user_ids" do
      get :share, params: { id: run_time_object.id }

      expect(assigns(:run_time_object)).to eq(run_time_object)
      expect(assigns(:users)).to include(user, another_user)
      expect(assigns(:permitted_user_ids)).to eq(run_time_object.run_time_objects_permissions.pluck(:user_id))
    end
  end

  describe "POST #share_with_users" do
    #let!(:permission) {RunTimeObjectsPermission.create(run_time_object: run_time_object, user: another_user, permission: 'r')}

    context "when user_ids are provided" do
      it "updates permissions by adding and removing as needed" do
        selected_user_ids = [user.id]

        post :share_with_users, params: { id: run_time_object.id, user_ids: selected_user_ids }

        expect(run_time_object.run_time_objects_permissions.exists?(user_id: another_user.id)).to be_falsey

        expect(run_time_object.run_time_objects_permissions.exists?(user_id: user.id)).to be_truthy
      end
    end

    context "when no user_ids are provided" do
      it "removes all permissions" do
        post :share_with_users, params: { id: run_time_object.id, user_ids: [] }

        expect(run_time_object.run_time_objects_permissions.exists?(user_id: another_user.id)).to be_falsey
        expect(run_time_object.run_time_objects_permissions.exists?(user_id: user.id)).to be_falsey
      end
    end
  end
end
