class RunTimeObjectsController < ApplicationController
  before_action :set_run_time_object, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_share_permission, only: [ :share ]
  before_action :authorize_edit_permission, only: [ :edit, :update ]

  # GET /run_time_objects
  def index
    if @current_user.admin
      @run_time_objects = RunTimeObject.all
    else
      owned_objects = RunTimeObject.where(user_id: @current_user.id)

      shared_ids = RunTimeObject.joins(:run_time_objects_permissions)
                              .where(run_time_objects_permissions: { user_id: @current_user.id })
                              .select(:id)

      @run_time_objects = RunTimeObject.where(user_id: @current_user.id)
                                      .or(RunTimeObject.where(id: shared_ids))
    end

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
    @run_time_object.user = current_user

    if @run_time_object.save
      redirect_to @run_time_object
    else
      render :new
    end
  end

  def destroy
    @run_time_object = RunTimeObject.find(params[:id])
    if @run_time_object.user == current_user || @current_user.admin
      ActiveRecord::Base.transaction do
        begin
          @run_time_object.destroy!
          flash[:success] = "Runtime object was successfully deleted."
          redirect_to run_time_objects_path
        rescue ActiveRecord::RecordNotDestroyed => e
          flash[:error] = "There was an error deleting the runtime object: #{e.message}"
          redirect_to @run_time_object
        end
      end
    end
  end

  # GET /run_time_objects/:id/edit
  def edit
    # The @run_time_object is already set by the before_action
  end

  # PATCH/PUT /run_time_objects/:id
  def update
    if @run_time_object.update(run_time_object_params)
      flash[:success] = "Runtime object was successfully updated."
      redirect_to @run_time_object
    end
  end
  def share
    @run_time_object = RunTimeObject.find(params[:id])
    @users = User.where.not(id: @run_time_object.user_id)
    @view_permitted_user_ids = @run_time_object.run_time_objects_permissions.where(permission: "r").pluck(:user_id)
    @edit_permitted_user_ids = @run_time_object.run_time_objects_permissions.where(permission: "e").pluck(:user_id)
  end

  def share_with_users
    @run_time_object = RunTimeObject.find(params[:id])
    selected_permission_user_ids = params[:permissions] || []

    @run_time_object
      .run_time_objects_permissions
      .where.not(user_id: selected_permission_user_ids)
      .destroy_all

    selected_permission_user_ids.each do |user_id, permission_type|
      permission = @run_time_object.run_time_objects_permissions.find_or_initialize_by(user_id: user_id)

      if permission_type == "view"
        permission.permission = "r"  # 'r' means view
      elsif permission_type == "edit"
        permission.permission = "e"  # 'e' means edit
      end
      permission.save
    end

    redirect_to @run_time_object
  end

  private

  def authorize_share_permission
    @run_time_object = RunTimeObject.find(params[:id])
    user_obj = User.find(session[:user_id])
    if !user_obj.admin? && @run_time_object.user.id != user_obj.id
      flash[:alert] = "You are not authorized to share this run time object."
      redirect_to run_time_objects_path
    end
  end

  def authorize_edit_permission
    @run_time_object = RunTimeObject.find(params[:id])
    user_obj = User.find(session[:user_id])
    unless user_obj.admin? || @run_time_object.user == user_obj || @run_time_object.run_time_objects_permissions.exists?(user_id: user_obj.id, permission: "e")
      flash[:alert] = "You are not authorized to edit this object."
      redirect_to run_time_objects_path
    end
  end

  # Set the RunTimeObject for the actions
  def set_run_time_object
    @run_time_object = RunTimeObject.find(params[:id])
  end

  def run_time_object_params
    params.require(:run_time_object).permit(:name, :description)
  end
end
