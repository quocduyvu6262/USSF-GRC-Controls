# app/controllers/tags_controller.rb
class TagsController < ApplicationController
    def show
      @tag = params[:id]  # Assuming the tag is passed as the ID
      @user = current_user
    end

    def new
      @user = current_user
    end
end
