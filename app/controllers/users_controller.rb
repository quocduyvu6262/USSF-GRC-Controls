class UsersController < ApplicationController
    def show
      tempemail = "testuser@gmail.com"  # Use the email you seeded
      user = User.find_by(email: tempemail)

      if user.present?  # Check if user exists
        @rto_list = RunTimeObject.where(user_id: user.id)  # Fetch RTOs for that user
        @image_list = Image.where(run_time_object_id: @rto_list.pluck(:id))  # Fetch images
      end
    end
end
