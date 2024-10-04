# app/controllers/tags_controller.rb
class TagsController < ApplicationController
    def show
      @tag = params[:id]  # Assuming the tag is passed as the ID
      @user = current_user
    end

    def new
      @user = current_user
    end
    #scan image based on parameter 


    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end

    def create
      @image = Image.new(image_params)
      if @image.save
        redirect_to @image, notice: 'Image was successfully created.'
      else
        render :new
      end
    end

    
    def scan_image
      @result = `trivy image python:3.4-alpine`
      if $?.exitstatus != 0
        @error_message = "Error running Trivy"
      end
    end
end
