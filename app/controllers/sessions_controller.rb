class SessionsController < ApplicationController
  skip_before_filter :authorize

  def new
  end

  def create
    profile = Profile.find_by_email(params[:email])
    if profile and profile.authenticate(params[:password])
      session[:profile_id] = profile.id
      redirect_to "/admin/ads" #admin_url
    else
      redirect_to login_url, alert: "Invalid email/password combination"
    end
  end

  def destroy
    session[:profile_id] = nil
    redirect_to "/", notice: "Logged out"
  end
end
