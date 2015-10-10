class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  before_action :force_http_authentication


  private

  # Force basic http authentication for the entire app, except in the callback url:
  def force_http_authentication
    if Rails.env.production? && ! ( request.params['controller'] == 'mangopay' && request.params['action'] == 'callback' )
      # request.full_path != '/resources/mangopay/callback'
      #http_basic_authenticate_with name: ENV['PCONF_HTTP_AUTH_USERNAME'], password: ENV['PCONF_HTTP_AUTH_PASSWORD'] if Rails.env.production?
      authenticate_or_request_with_http_basic 'Test ENV'  do |name, password|
        #PCONF_HTTP_AUTH_CRED_LIST="user:secret,user2:password2"
        authenticated = false

        if (ENV.has_key? 'PCONF_HTTP_AUTH_CRED_LIST') && (ENV['PCONF_HTTP_AUTH_CRED_LIST'].split(',').include? "#{name}:#{password}")
          authenticated = true
        end

        if (ENV.has_key? 'PCONF_HTTP_AUTH_USERNAME') && (ENV.has_key? 'PCONF_HTTP_AUTH_PASSWORD') && 
              name == ENV['PCONF_HTTP_AUTH_USERNAME'] && password == ENV['PCONF_HTTP_AUTH_PASSWORD'] then
          authenticated = true
        end

        authenticated
      end
    end

    # extra password protection in admin pages:
    # should also REQUIRE SSL!
    #if request.params['controller'].starts_with? 'admin'
    #  authenticate_or_request_with_http_basic 'Test ENV'  do |name, password|
    #    #name == ENV['PCONF_HTTP_AUTH_ADMIN_USERNAME'] && password == ENV['PCONF_HTTP_AUTH_ADMIN_PASSWORD']
    #    name == ENV['PCONF_HTTP_AUTH_USERNAME'] && password == ENV['PCONF_HTTP_AUTH_PASSWORD']
    #  end
    #end
  end


  protected

  # required by active_admin when a user is not authorized.
  def access_denied(exception)
    redirect_to root_path, notice: "You are not authorized to see this page: #{exception.message}"
  end

  def current_user
    UserDecorator.decorate(super) unless super.nil?
  end
end
