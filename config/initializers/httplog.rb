
# HttpLog is not enabled in production.
if defined? HttpLog
  #HttpLog.options[:logger] = Rails.logger
  #HttpLog.options[:logger] = Logger.new($stdout)

  if Rails.env.production?
    # in production only log calls to mangopay
    HttpLog.options[:url_whitelist_pattern] = /https\:\/\/api\.mangopay\.com\/(.*)/
  else
    # everywhere except monitoring
    HttpLog.options[:url_blacklist_pattern] = /http(s?)\:\/\/(.*)(newrelic\.com|airbrake\.io|hooks\.slack\.com|localhost)(\:[0-9]*|)/
  end
end