require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  describe 'GET #index' do
    context 'when user is logged in' do
      before do
        @user = User.create(
          first_name: "John",
          last_name: "Doe",
          email: "john.doe@example.com",
          uid: "123456",
          provider: "google_oauth2"
        )

        session[:user_id] = @user.id
      end

      it 'redirects to the user page' do
        get :index
        expect(response).to redirect_to(run_time_objects_path)
      end
    end

    context 'when user is not logged in' do
      before do
        session[:user_id] = nil
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end
    end
  end
end
