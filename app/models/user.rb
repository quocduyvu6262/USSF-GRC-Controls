class User < ApplicationRecord
  validates :email, presence: true
  has_many :run_time_objects, dependent: :destroy
  has_many :run_time_objects_permissions, dependent: :destroy
  has_many :shared_run_time_objects, through: :run_time_objects_permissions, source: :run_time_object
end
