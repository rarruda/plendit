class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :force_http_authentication

  before_action :enable_chat


  private

  def enable_chat
    @purechat_enabled = Plendit::Application.config.x.purechat_integration
  end

  # Force basic http authentication for the entire app, except in some callback urls:
  #PCONF_HTTP_AUTH_CRED_LIST="user:secret,user2:password2"
  def force_http_authentication
    authenticate_or_request_with_http_basic 'Authentication required'  do |name, password|
      ( ENV.has_key? 'PCONF_HTTP_AUTH_CRED_LIST' ) && ( ENV['PCONF_HTTP_AUTH_CRED_LIST'].split(',').include? "#{name}:#{password}" )
    end if require_http_authentication?
  end

  def require_http_authentication?
    ! ( ( ['/privacy', '/resources/mangopay/callback'].include? request.path ) ||
        ( request.path =~ /\/me\/auth\/(\w+)\/callback/ ) ||
        Rails.env.production? )
  end


  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  protected

  # required by active_admin when a user is not authorized.
  def access_denied(exception)
    redirect_to root_path, notice: "You are not authorized to see this page: #{exception.message}"
  end

  def current_user
    ::UserDecorator.decorate(super) unless super.nil?
  end
end
