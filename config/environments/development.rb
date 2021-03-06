Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # to enable some caching for testing varnish (client caching):
  #config.static_cache_control = "public, max-age=#{1.hour.to_i}"

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Devise setting:
  config.action_mailer.default_url_options = {
    # if hostname starts with 'sbox-plendit-dev' send to dev.plendit.com, otherwise
    # assume we are running plendit locally.
    host: ( Socket.gethostname =~ /^sbox-plendit-dev/ ) ? 'dev.plendit.com' : 'localhost:3000'
  }

  config.action_mailer.raise_delivery_errors = true
  ## Maybe we should not be sending out emails in dev? For now we send emails...
  ##  but to disable again: (not such a bad idea)
  # config.action_mailer.perform_deliveries = false
  config.action_mailer.perform_deliveries = true

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    port:      1025,        #ENV['PCONF_SMTP_PORT'] || 465,
    address:   'localhost', #ENV['PCONF_SMTP_ADDRESS'],
    #user_name: ENV['PCONF_SMTP_USERNAME'],
    #password:  ENV['PCONF_SMTP_PASSWORD'],
    #tls:       true,
  }

  # for ugh, generating routes within models: (reuse value from action_mailer)
  routes.default_url_options = config.action_mailer.default_url_options
end
