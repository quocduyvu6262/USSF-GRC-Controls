require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
    describe 'GET #logout' do
    it 'resets the session and redirects to welcome path' do
      user = User.create!(
        email: 'test@example.com',
        uid: '123456789',
        provider: 'google_oauth2',
        first_name: 'John',
        last_name: 'Doe'
      )

      session[:user_id] = user.id

      get :logout

      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(welcome_path)
    end
  end

  describe 'GET #omniauth' do
    context 'when login is successful' do
      before do
        request.env['omniauth.auth'] = OmniAuth::AuthHash.new({
          provider: 'google_oauth2',
          uid: '123456789',
          info: {
            email: 'test@example.com',
            name: 'John Doe'
          }
        })
      end

      it 'creates a user and redirects to user path' do
        get :omniauth
        user = User.find_by(email: 'test@example.com')
        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(user_path(user))
      end
    end

    context 'when login fails (invalid user)' do
      before do
        request.env['omniauth.auth'] = OmniAuth::AuthHash.new({
          provider: 'google_oauth2',
          uid: '123456789',
          info: {
            email: nil,
            name: 'John Doe'
          }
        })
      end

      it 'does not create a user and redirects to welcome path with alert' do
        get :omniauth
        user = User.find_by(email: nil)
        expect(user).to be_nil
        expect(response).to redirect_to(welcome_path)
      end
    end

    context 'when access is denied by the user' do
      it 'redirects to the welcome path' do
        get :omniauth, params: { error: 'access_denied' }
        expect(response).to redirect_to(welcome_path)
      end
    end
  end

  describe 'GET #failure' do
    it 'redirects to the welcome path' do
      get :failure
      expect(response).to redirect_to(welcome_path)
    end
  end
end
