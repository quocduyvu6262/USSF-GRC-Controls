require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'creating a user' do
    it 'is valid with an email' do
      user = User.new(email: 'example@example.com', first_name: 'John', last_name: 'Doe')
      expect(user).to be_valid
    end

    it 'is invalid without an email' do
      user = User.new(first_name: 'John', last_name: 'Doe')
      expect(user).to_not be_valid
    end
  end
end
