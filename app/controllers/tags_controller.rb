# app/controllers/tags_controller.rb
class TagsController < ApplicationController
    def show
      @tag = params[:id]  # Assuming the tag is passed as the ID
    end

    def new
    end

end
  