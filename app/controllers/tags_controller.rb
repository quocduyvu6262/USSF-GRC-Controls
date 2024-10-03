# app/controllers/tags_controller.rb
class TagsController < ApplicationController
    def show
      @tag = params[:id]  # Assuming the tag is passed as the ID
      # You can also retrieve associated records or data based on the tag here.
    end
end
  