class RunTimeObjectsPermission < ApplicationRecord
  belongs_to :runtime_object
  belongs_to :user
end
