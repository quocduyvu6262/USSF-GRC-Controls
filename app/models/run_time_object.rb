class RunTimeObject < ApplicationRecord
  belongs_to :user
  has_many :images, dependent: :destroy
  has_many :run_time_objects_permissions, dependent: :destroy
  has_many :shared_users, through: :run_time_objects_permissions, source: :user, dependent: :destroy

  validates :name, presence: true
end
