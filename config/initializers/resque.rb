# Resque has its own connection/pool to redis:
Resque.redis = Redis.new( url: ( ENV['PCONF_REDIS_URL'] || ENV['REDIS_URL'] ) )