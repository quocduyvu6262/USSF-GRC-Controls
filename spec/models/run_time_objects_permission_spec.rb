require 'rails_helper'

RSpec.describe RunTimeObjectsPermission, type: :model do
    let(:user) { User.create(email: "test@example.com", first_name: "Test", last_name: "User") }
    let(:run_time_object) { RunTimeObject.create(name: "Sample Object", description: "A sample runtime object", user: user) }
    
    context "associations" do
        it "is invalid without a run_time_object" do
            permission = RunTimeObjectsPermission.new(run_time_object: nil, user: user, permission: 'r')
            expect(permission).not_to be_valid
        end
      
        it "is invalid without a user" do
            permission = RunTimeObjectsPermission.new(run_time_object: run_time_object, user: nil, permission: 'r')
            expect(permission).not_to be_valid
        end

        it "valid with user and runtime object" do
            permission = RunTimeObjectsPermission.new(run_time_object: run_time_object, user: user, permission: 'r')
            expect(permission).to be_valid
        end

    end
end
