class AdminAuthorization < ActiveAdmin::AuthorizationAdapter

  # http://activeadmin.info/docs/13-authorization-adapter.html
  def authorized?(action, subject = nil)
    ## consider adding some accounting:
    #LOG.info message: "checking authorization for u: #{user}"
    # if not user.is_site_admin?
    ##  LOG.tagged("user_id:#{user.id}") {
    ##    LOG.error message: "User not authorized to see this page."
    ##  }
    # end
    user.is_site_admin?
  end

end