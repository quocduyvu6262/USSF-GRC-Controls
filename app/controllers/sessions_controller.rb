class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :omniauth, :failure ]
  # GET /logout
  def logout
    reset_session
    redirect_to welcome_path
  end

  # GET /auth/google_oauth2/callback
  def omniauth
    if params[:error] == "access_denied"
      redirect_to welcome_path
      return
    end

    auth = request.env["omniauth.auth"]
    @user = User.find_or_create_by(uid: auth["uid"], provider: auth["provider"]) do |u|
      u.email = auth["info"]["email"]
      names = auth["info"]["name"].split
      u.first_name = names[0]
      u.last_name = names[1..].join(" ")
    end

    if @user.block?
      redirect_to welcome_path, alert: "Your account has been blocked."
      return
    end

    if @user.valid?
      session[:user_id] = @user.id
      redirect_to run_time_objects_path()
    else
      redirect_to welcome_path, alert: "Login failed."
    end
  end

  def failure
    redirect_to welcome_path
  end
end
