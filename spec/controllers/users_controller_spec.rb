require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  let(:admin_user) { User.create(email: "test@example.com", first_name: "Test", last_name: "User",admin:true) }
  let(:normal_user) { User.create(email: "normal@example.com", first_name: "Normal", last_name: "User") }

  
  describe 'before actions' do
    context 'when the user is not an admin' do
      before do
        session[:user_id] = normal_user.id
      end
      it 'redirects to root_path with an alert' do
        get :manage
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to access this page.')
      end
    end
  end

  describe 'GET #manage' do
    before do
      session[:user_id] = admin_user.id
    end
    it 'renders the users admin screen' do
      get :manage
      expect(assigns(:display_users_admin_screen)).to include(normal_user)
      expect(assigns(:display_users_admin_screen)).not_to include(admin_user)
    end
  end

  describe 'PATCH #update_admin_status' do
    before do
      session[:user_id] = admin_user.id
    end
 
    it 'updates the admin status of users' do
      patch :update_admin_status, params: {
        admin_user_ids: [normal_user.id]
      }

      expect(normal_user.admin?)
      expect(flash[:notice]).to eq("User statuses updated successfully.")
    end

    it 'updates the block status of users' do
      patch :update_admin_status, params: {
        block_user_ids: [normal_user.id]
      }

      expect(normal_user.block?)
      expect(flash[:notice]).to eq("User statuses updated successfully.")
    end

    it 'does not update the current user' do
      patch :update_admin_status, params: {
        admin_user_ids: [normal_user.id.to_s]
      }

      admin_user.reload
      expect(admin_user.admin?).to be_truthy
    end
  end

  describe 'DELETE #destroy' do
    before do
      session[:user_id] = admin_user.id
    end
    it 'destroys the user and redirects to manage users' do
      delete :destroy, params: { id: normal_user.id }

      expect(flash[:notice]).to eq("User deleted successfully.")
    end
  end
end
