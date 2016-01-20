
# HttpLog is not enabled in production.
if defined? HttpLog
  HttpLog.options[:url_blacklist_pattern] = "http(s?)\://(.*)(newrelic\.com|airbrake\.io|localhost)(\:[0-9]*|)"
end