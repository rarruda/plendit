module SessionsHelper

  def get_current_user_id
    session["warden.user.user.key"][0][0]
  end
end
