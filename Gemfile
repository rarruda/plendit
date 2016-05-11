source 'https://rubygems.org'
ruby '2.1.6'
#ruby '2.2.4'

gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-spid'
gem 'switch_user'
gem 'devise-async'

gem 'geocoder'

gem 'twilio-ruby', '~> 4'

gem 'paperclip', '~> 4.2'
gem 'aws-sdk', '< 2.0'
gem 'dropzonejs-rails'

gem 'activeadmin', '~> 1.0.0.pre1'

# kaminari needs to come before elasticsearch gems
gem 'kaminari'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'

gem 'aasm', '~> 4'

gem 'paper_trail', '~> 4.0.0'

gem 'rolify', '~> 4'

gem 'time_splitter', '>= 1.1.0'
gem 'validates_overlap'

# payment gems:
gem 'mangopay', '~> 3.0.20'
gem 'ibanizator', '~> 0.3.1'
gem 'mod11'

# possibly replace this with https://github.com/kpumuk/meta-tags
gem 'metamagic'

# Make google index ads correctly: (fog for uploading to s3)
gem 'sitemap_generator'
gem 'fog-aws'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.1'
gem 'rails-i18n', '~> 4.0'

gem 'country_select'
gem 'world-flags'

gem 'draper', '~> 1.3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc


# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Passenger as the app server
gem 'passenger', '~> 5.0.28'

# postgresql is required for both production and development
gem 'pg'

# Redis used for event queuing and caching
gem 'redis', '~> 3.2.1'
# for connection pooling redis:
#gem 'connection_pool', '~> 2.2.0'
gem 'resque'
gem 'resque-web', require: 'resque_web'
gem 'resque-scheduler'
gem 'resque-loner'
gem 'capistrano-resque', "~> 0.2.2", require: false

# fragment caching and sessions can use redis
gem 'redis-rails'

# health check for the app:
gem 'okcomputer'

# newrelic:
gem 'newrelic_rpm'

# icons for the UI
gem 'font-awesome-sass'

# prefix CSS rules that need it
gem 'autoprefixer-rails'

gem 'rschema'

gem 'nested_form_fields'

gem 'recursive-open-struct'

# for markdown views
gem 'html_pipeline_rails'

# for writing email in both text and html from markdown:
#gem 'markerb'
#gem 'redcarpet'

# Need acts-as-taggable-on for when running migrations all the way from the start of history
gem 'acts-as-taggable-on', '~> 3.4'

# Get notified about exceptions:
# https://github.com/smartinez87/exception_notification
# gem 'exception_notification'
gem 'airbrake', '~> 5.3'

# Trace http calls to the outside world.
gem 'httplog'

# logging:
gem 'lograge'
gem 'logstash-event'
gem 'logstash-logger'
#gem 'rails_semantic_logger'
#gem 'cabin'

# notifications
gem 'slack-notifier'

group :development, :test do
  # Use Capistrano for deployment
  gem 'capistrano',           require: false
  gem 'capistrano-rvm',       require: false
  gem 'capistrano-rails',     require: false
  gem 'capistrano-bundler',   require: false
  gem 'capistrano-passenger', require: false
  gem 'slackistrano',         require: false
  #gem 'capistrano-ext'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Get some better errors
  gem 'better_errors'
  gem 'binding_of_caller'

  # No more need to keep tailing development.log. Send information about the request back to google chrome.
  # Requires an extension to chrome to work. Read more: https://github.com/dejan/rails_panel
  gem 'meta_request'

  # To respect DRY principle, generate documentation/diagrams from source code:
  gem 'rails-erd'
  gem 'railroady'

  # rspec testing is nice to have:
  gem 'rspec-rails', '~> 3.0'
  gem 'guard-rspec', require: false


  # Ruby static code analyzer:
  gem 'rubocop'
  gem 'guard-rubocop', require: false


  # static code analyzer, for security issues
  # https://github.com/presidentbeef/brakeman
  # gem 'brakeman', require: false

end

group :development do
  gem 'mailcatcher'
  # Uncomment next line to get debug info about translation resolving
  #gem 'i18n-debug'
end

group :test do
  gem 'capybara'
  #gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'selenium-webdriver'
  gem 'factory_girl_rails'

  # to read on, for keeping the database clean:
  # https://github.com/DatabaseCleaner/database_cleaner
  #gem 'database_cleaner'

  # to generate fake data to rake db:seed the database:
  gem 'faker'
  # Consider using it later for future generation of seed data:
  #gem 'seed_dump'

  # mock/prevent http calls from going out to the world
  gem 'webmock'
  #gem 'vcr'
end

group :production do
end


gem 'rails-console-tweaks'
group :console do # Gems to increase readability of rails console output, especially database tables.
  gem 'hirb'
  gem 'wirb' # important that this comes after hirb, not before it, in the Gemfile
  gem 'awesome_print' # In the rails console, get full line-by-line output by writing i.e.: ap User.all
end
