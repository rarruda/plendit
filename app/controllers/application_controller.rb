class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authorize


  protected
  def authorize
    unless Profile.find_by_id( session[:profile_id] )
      redirect_to :login, notice: "Please log in"
    end
  end

end
