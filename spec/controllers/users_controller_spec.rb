require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "UsersController" do
    it "should be defined" do
      expect(defined?(UsersController)).to eq('constant')
      expect(UsersController.is_a?(Class)).to be true
    end

    it "should be a subclass of ApplicationController" do
      expect(UsersController.superclass).to eq(ApplicationController)
    end
  end
end