class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super
    flash[:notice] = nil # supress notice about successful login
  end

  # DELETE /resource/sign_out
  def destroy
    super
    flash[:notice] = nil # supress notice about successful logout
  end

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end

  def after_sign_in_path_for(resource)
    if resource.profile_complete?
      super resource
    else
      finish_signup_users_path(resource)
    end
  end

end
