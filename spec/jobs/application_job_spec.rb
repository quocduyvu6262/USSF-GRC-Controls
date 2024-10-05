require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  describe "job configuration" do
    it "inherits from ActiveJob::Base" do
      expect(ApplicationJob).to be < ActiveJob::Base
    end

    it "can be instantiated" do
      connection = ApplicationJob.new
      expect(connection).to be_instance_of(ApplicationJob)
    end
  end
end
