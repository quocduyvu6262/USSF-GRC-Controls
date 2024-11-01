class RunTimeObject < ApplicationRecord
  belongs_to :user
  has_many :images
  has_many :run_time_objects_permissions
  has_many :shared_users, through: :run_time_objects_permissions, source: :user

  validates :name, presence: true
end
