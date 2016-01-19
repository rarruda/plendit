Rails.application.configure do

  config.lograge.enabled = true

  config.lograge.formatter = Lograge::Formatters::Logstash.new

  config.lograge.custom_options = lambda do |event|
    params = event.payload[:params] #.reject do |k|
    #   ['controller', 'action'].include? k
    # end

    {time: event.time, params: params}
  end

  # Optional, Rails sets the default to :info
  #config.log_level = :debug

  # Optional. Defaults to :json_lines. If there are multiple outputs,
  # they will all share the same formatter.
  # config.logstash.formatter = :json_lines
  config.logstash.formatter = :logstash_event

  config.logger = LogStashLogger.new(type: :stdout, formatter: :logstash_event)
end

LOG = LogStashLogger.new(type: :stdout, formatter: :json_lines)
