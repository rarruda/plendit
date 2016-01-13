class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth


  # equivalent to: def facebook, def google, def spid
  [:facebook, :google, :spid].each do |provider|
    define_method "#{provider}" do
      @user = User.find_for_oauth(env["omniauth.auth"], current_user)

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
      else
        # fixme: this never happens, if it does, the code below is probably wrong.
        session["devise.#{provider}_data"] = env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end


  def after_sign_in_path_for(resource)
    if resource.profile_complete?
      super resource
    else
      finish_signup_users_path(resource)
    end
  end


  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when omniauth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
