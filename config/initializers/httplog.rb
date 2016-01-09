
# HttpLog is not enabled in production.
unless Rails.env.production?
  HttpLog.options[:url_blacklist_pattern] = "(.*)\.newrelic\.com(\:[0-9]*|)"
end