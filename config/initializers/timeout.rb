# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#timeout
Rack::Timeout.timeout = 20  # seconds
Rack::Timeout::Logger.level  = Logger::ERROR

#Rack::Timeout::Logger.logger = Logger.new
#Rack::Timeout::Logger.device = $stderr
#Rack::Timeout::Logger.disable

