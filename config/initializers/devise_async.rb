
Devise::Async.setup do |config|
  # Disabled for now:
  config.enabled = false
  config.backend = :resque
  config.queue   = :low
end