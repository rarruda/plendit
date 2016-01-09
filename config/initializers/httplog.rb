
# HttpLog is not enabled in production.
if defined? HttpLog
  HttpLog.options[:url_blacklist_pattern] = "(.*)\.newrelic\.com(\:[0-9]*|)"
end