class User < ApplicationRecord
  validates :email, presence: true
  has_many :run_time_objects
end
