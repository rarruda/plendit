require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Plendit
  class Application < Rails::Application
    config.before_configuration do
      env = Rails.root.join('config/env.yml')

      if env.exist?
        YAML.load(env.read).each { |k, v| ENV[k.to_s] = v.to_s }
      end
    end

    # to load the markdown handler. see
    # http://www.lugolabs.com/articles/18-render-markdown-views-with-redcarpet-and-pygment-in-rails
    config.autoload_paths += %W(#{config.root}/lib)

    # Set queuing backend:
    config.active_job.queue_adapter = :resque

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    ### For enabling translations in subdirectories:
    ###config.i18n.load_path += Dir[File.join(Rails.root, 'config', 'locales', '**', '*.{rb,yml}')]

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.autoload_paths += %W(#{config.root}/lib)
    config.cache_store = :redis_store, ( ENV['PCONF_REDIS_URL'] || ENV['REDIS_URL']), { expires_in: 15.minutes }
  end
end
