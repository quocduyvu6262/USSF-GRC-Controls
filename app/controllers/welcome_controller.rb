class WelcomeController < ApplicationController
  skip_before_action :require_login, only: [ :index ]
  def index
    if logged_in?
      redirect_to run_time_objects_path
    end
  end
end
