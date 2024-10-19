# spec/channels/application_cable/connection_spec.rb

require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  it "successfully connects" do
    connect "/cable"
    expect(connection).to be_present
  end

  # Add more tests as needed based on your connection logic
end
