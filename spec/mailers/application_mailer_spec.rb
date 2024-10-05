require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  describe "default values" do
    it "sets the default from address" do
      expect(ApplicationMailer.default_params[:from]).to eq("from@example.com")
    end
  end
end
