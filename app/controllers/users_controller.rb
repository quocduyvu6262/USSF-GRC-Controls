class UsersController < ApplicationController
  def show
    tempid = 1
    @rto_list = RunTimeObject.where(user_id: tempid)
    @pagy, @image_list = pagy(Image.all, steps: false)
  end
end
