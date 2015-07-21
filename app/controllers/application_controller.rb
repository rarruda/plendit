class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  http_basic_authenticate_with name: ENV['PCONF_HTTP_AUTH_USERNAME'], password: ENV['PCONF_HTTP_AUTH_PASSWORD'] if Rails.env.production?




  protected

  # required by active_admin when a user is not authorized.
  def access_denied(exception)
    redirect_to root_path, notice: "You are not authorized to see this page: #{exception.message}"
  end

end
