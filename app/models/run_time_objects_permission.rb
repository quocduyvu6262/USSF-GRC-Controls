class RunTimeObjectsPermission < ApplicationRecord
  belongs_to :run_time_object
  belongs_to :user
end
