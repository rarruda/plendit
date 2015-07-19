# Be sure to restart your server when you modify this file.

## NOTE: :secure => true should be configured to allow only logins over HTTPS
# if ENV != 'production'
Rails.application.config.session_store :cookie_store, key: '_plendit_session'
# else
#   Rails.application.config.session_store :cookie_store, { key: '_plendit_session', :secure => true }
# end