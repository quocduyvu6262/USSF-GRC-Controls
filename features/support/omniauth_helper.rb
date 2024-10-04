module OmniAuthHelper
    def mock_auth_hash(valid: true)
      if valid
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
          provider: 'google_oauth2',
          uid: '123456789',
          info: {
            email: 'test@example.com',
            first_name: 'John',
            last_name: 'Doe',
            name: 'John Doe'
          },
          credentials: {
            token: 'mock_token',
            refresh_token: 'mock_refresh_token',
            expires_at: Time.now + 1.week
          }
        })
      else
        OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
      end
    end
end

  World(OmniAuthHelper)
