class UsersController < ApplicationController
  def show
    @current_user = User.find(params[:id])
    @rto_list = RunTimeObject.where(user_id: @current_user.id)
    @image_list = Image.where(run_time_object_id: @rto_list.pluck(:id))
  end
end
