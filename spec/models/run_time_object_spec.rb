require 'rails_helper'

RSpec.describe RunTimeObject, type: :model do
  let(:user) { User.create(email: "test@example.com", first_name: "Test", last_name: "User") }

  context 'validations' do
    it 'is valid with a user' do
      run_time_object = RunTimeObject.new(name: "Sample Object", description: "A sample runtime object", user: user)
      expect(run_time_object).to be_valid
    end

    it 'is invalid without a user' do
      run_time_object = RunTimeObject.new(name: "Sample Object", description: "A sample runtime object")
      expect(run_time_object).to be_invalid
    end
  end
end
