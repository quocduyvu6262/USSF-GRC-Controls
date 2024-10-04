require 'rails_helper'

RSpec.describe Image, type: :model do
  let(:user) { User.create(email: "test@example.com", first_name: "Test", last_name: "User") }
  let(:run_time_object) { RunTimeObject.create(name: "Sample Object", description: "A sample runtime object", user: user) }

  context 'validations' do
    it 'is valid with a runtime object' do
      image = Image.new(tag: "Sample Tag", report: "A sample report", run_time_object: run_time_object)
      expect(image).to be_valid
    end

    it 'is invalid without a runtime object' do
      image = Image.new(tag: "Sample Tag", report: "A sample report")
      expect(image).to be_invalid
    end
  end
end
