class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  http_basic_authenticate_with name: ENV['PCONF_HTTP_AUTH_USERNAME'], password: ENV['PCONF_HTTP_AUTH_PASSWORD'] if Rails.env.production?

  # does not work:
  #before_action :force_http_authentication



  private

  # This does not work!
  def force_http_authentication
    if Rails.env.production? &&
      ( request.params['controller'] != 'misc' && request.params['action'] != 'mangopay_callback' )
      authenticate_or_request_with_http_basic 'Test ENV'  do |name, password|
        name == ENV['PCONF_HTTP_AUTH_USERNAME'] && password == ENV['PCONF_HTTP_AUTH_PASSWORD']
      end
    end
  end

  # extra password protection in admin pages:
  # should also REQUIRE SSL!
  #if request.params['controller'] == 'admin'
  #  http_basic_authenticate_with name: ENV['PCONF_HTTP_AUTH_USERNAME'], password: ENV['PCONF_HTTP_AUTH_PASSWORD']
  #end


  protected

  # required by active_admin when a user is not authorized.
  def access_denied(exception)
    redirect_to root_path, notice: "You are not authorized to see this page: #{exception.message}"
  end

  def current_user
    UserDecorator.decorate(super) unless super.nil?
  end
end
