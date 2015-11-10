  # configure REDIS
  # consider connection pooling: https://github.com/mperham/connection_pool
  unless defined? REDIS
    REDIS = Redis.new( url: ( ENV['PCONF_REDIS_URL'] || ENV['REDIS_URL'] ) )
  end
