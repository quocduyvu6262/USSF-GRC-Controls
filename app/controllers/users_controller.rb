class UsersController < ApplicationController
  def show
    tempid = 1
    @rto_list = RunTimeObject.where(user_id: tempid)
    @pagy, @image_list = pagy(Image.where(run_time_object_id: @rto_list.pluck(:id)), steps: false)
  end
end
