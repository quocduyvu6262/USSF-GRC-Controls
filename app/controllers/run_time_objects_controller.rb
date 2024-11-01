class RunTimeObjectsController < ApplicationController
  def share
    @run_time_object = RunTimeObject.find(1)
    # @users = User.where.not(id: @run_time_object.user_id)
    @users = User.all
    @permitted_user_ids = @run_time_object.run_time_objects_permissions.pluck(:user_id)
  end

  def share_with_users

    @run_time_object = RunTimeObject.find(params[:id])
    selected_user_ids = params[:user_ids] || []

    @run_time_object.run_time_objects_permissions.where.not(user_id: selected_user_ids).destroy_all

    selected_user_ids.each do |user_id|
      unless @run_time_object.run_time_objects_permissions.exists?(user_id: user_id)
        RunTimeObjectsPermission.create(run_time_object: @run_time_object, user_id: user_id, permission: "r")
      end
    end

    #redirect_to user_path(@current_user)

    # redirect_to @run_time_object, notice: 'RunTimeObject has been shared successfully.'
  end
end
