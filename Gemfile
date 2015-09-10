source 'https://rubygems.org'
ruby '2.1.6'

gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-spid'
gem 'switch_user'

gem 'geocoder'

gem 'twilio-ruby', '~> 4'

gem 'paperclip', '~> 4.2'
gem 'aws-sdk', '< 2.0'
gem 'dropzonejs-rails'
gem 'acts-as-taggable-on', '~> 3.4'

gem 'activeadmin', '~> 1.0.0.pre1'

# kaminari needs to come before elasticsearch gems
gem 'kaminari'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'

gem 'aasm', '~> 4'

gem 'rolify', '~> 4'

gem 'time_splitter', '>= 1.1.0'
gem 'validates_overlap'


gem 'mangopay', '~> 3.0.18'
gem 'ibanizator', '~> 0.3.1'
gem 'mod11'

# possibly replace this with https://github.com/kpumuk/meta-tags
gem 'metamagic'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
gem 'rails-i18n', '~> 4.0'

# for selecting nationality:
#gem 'country_select'


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

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# to generate fake data to rake db:seed the database:
gem 'faker'
# Consider using it later for future generation of seed data:
#gem 'seed_dump'

# postgresql is required for both production and development
gem 'pg'

# icons for the UI
gem 'evil_icons'

# prefix CSS rules that need it
gem "autoprefixer-rails"

group :development, :test do
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

  gem 'factory_girl_rails'
  #gem 'faker'

  # Trace every http call to the outside world that rails makes.
  #gem 'httplog'
end

group :production do
  # this gem is important to run in heroku. Enables static assets, and routes logs to stdout.
  # https://github.com/heroku/rails_12factor
  gem 'rails_12factor'
end
