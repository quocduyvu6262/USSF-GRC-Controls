require 'rails_helper'

RSpec.describe ApplicationCable::Channel, type: :channel do
  it "inherits from ActionCable::Channel::Base" do
    expect(ApplicationCable::Channel).to be < ActionCable::Channel::Base
  end
end
