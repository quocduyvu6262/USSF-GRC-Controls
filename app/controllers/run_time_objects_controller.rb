class RunTimeObjectsController < ApplicationController
  before_action :set_run_time_object, only: [ :show ]

  # GET /run_time_objects
  def index
    @run_time_objects = RunTimeObject.all
    @pagy, @run_time_objects = pagy(@run_time_objects)
  end

  # GET /run_time_objects/:id
  def show
    redirect_to run_time_object_images_path(@run_time_object)
  end


  # GET /run_time_objects/new
  def new
    @run_time_object = RunTimeObject.new
  end

  # POST /run_time_objects
  def create
    @run_time_object = RunTimeObject.new(run_time_object_params)
    @run_time_object.user = current_user # Assuming you have a current_user method for authentication

    if @run_time_object.save
      redirect_to @run_time_object, notice: "Run Time Object was successfully created."
    else
      render :new
    end
  end

  def share
    @run_time_object = RunTimeObject.find(1)
    # @users = User.where.not(id: @run_time_object.user_id)
    @users = User.all
    @permitted_user_ids = @run_time_object.run_time_objects_permissions.pluck(:user_id)
  end

  def share_with_users

    @run_time_object = RunTimeObject.find(params[:id])
    selected_user_ids = params[:user_ids] || []

    # Remove permissions for users who are no longer selected
    @run_time_object.run_time_objects_permissions.where.not(user_id: selected_user_ids).destroy_all

    # Add permissions for selected users if they don't already have them
    selected_user_ids.each do |user_id|
      unless @run_time_object.run_time_objects_permissions.exists?(user_id: user_id)
        RunTimeObjectsPermission.create(run_time_object: @run_time_object, user_id: user_id, permission: "r")
      end
    end

    redirect_to user_path(@current_user)

    # redirect_to @run_time_object, notice: 'RunTimeObject has been shared successfully.'
  end

  private

  # Set the RunTimeObject for the actions
  def set_run_time_object
    @run_time_object = RunTimeObject.find(params[:id])
  end

  def run_time_object_params
    params.require(:run_time_object).permit(:name, :description)
  end
end
