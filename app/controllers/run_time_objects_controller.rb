class RunTimeObjectsController < ApplicationController
  before_action :set_run_time_object, only: [:show, :edit, :update, :destroy]

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
      redirect_to @run_time_object, notice: 'Run Time Object was successfully created.'
    else
      render :new
    end
  end

  # GET /run_time_objects/:id/edit
  def edit
  end

  # PATCH/PUT /run_time_objects/:id
  def update
    if @run_time_object.update(run_time_object_params)
      redirect_to @run_time_object, notice: 'Run Time Object was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /run_time_objects/:id
  def destroy
    @run_time_object.destroy
    redirect_to run_time_objects_url, notice: 'Run Time Object was successfully destroyed.'
  end

  private

  # Set the RunTimeObject for the actions
  def set_run_time_object
    @run_time_object = RunTimeObject.find(params[:id])
  end

  # Permit parameters for RunTimeObject
  def run_time_object_params
    params.require(:run_time_object).permit(:attribute1, :attribute2) # Replace with actual attributes
  end
end
