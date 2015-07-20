class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  http_basic_authenticate_with name: ENV['PCONF_HTTP_AUTH_USERNAME'], password: ENV['PCONF_HTTP_AUTH_PASSWORD'] if Rails.env.production?


  before_filter :configure_sign_up_params, if: :devise_controller?

  protected

  # You can put the params you want to permit in the empty array.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up){ |u| u.permit( :name, :email, :phone_number, :password, :password_confirmation ) }
  end

  # required by active_admin when a user is not authorized.
  def access_denied(exception)
    redirect_to root_path, notice: "You are not authorized to see this page: #{exception.message}"
  end

end
