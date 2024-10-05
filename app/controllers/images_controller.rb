class ImagesController < ApplicationController
  before_action :set_image, only: %i[ show edit update destroy ]

  # GET /images or /images.json
  def index
    @images = Image.all
  end

  # def show
  #   @tag = params[:id]  # Assuming the tag is passed as the ID
  #   @user = current_user
  # end

  def show
    @tag = params[:id]  # Assuming the tag is passed as the ID
    @user = current_user
    @image_report = @image.report  # This will be displayed as HTML in the view
  end


  def new
    @user = current_user
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images or /images.json
  # def create
  #   @image = Image.new(image_params)
  #   @image.report = `trivy image python:3.4-alpine 2>&1`
  #   puts @image.report
  #   if @image.save  # Try to save the image
  #     redirect_to @image, notice: 'Image was successfully scanned.'  # Redirect on success
  #   else
  #     render :new  # Render the new template if there are validation errors
  #   end
  # end

  def create
    # comment
    @user = current_user  # Ensure @user is set
    @image = Image.new(image_params)

    # Fetch the image name from the tag (which is provided as a URL field input)
    image_name = params[:image][:tag]

    # Perform trivy scan for the image from URL
    @image.report = `trivy image #{image_name} 2>&1` # Run trivy scan on the provided image name
    puts @image.report

    if @image.save
      redirect_to @image
    else
      redirect_to new_image_path
    end
  end


  # PATCH/PUT /images/1 or /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to @image, notice: "Image was successfully updated." }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1 or /images/1.json
  def destroy
    @image.destroy!

    respond_to do |format|
      format.html { redirect_to images_path, status: :see_other, notice: "Image was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end


    # Only allow a list of trusted parameters through.
    def image_params
      params.require(:image).permit(:tag, :run_time_object_id, :created_at, :updated_at)
    end
end
