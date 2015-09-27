
OkComputer.mount_at = false

#OkComputer.require_authentication(ENV['PCONF_HTTP_AUTH_USERNAME'], ENV['PCONF_HTTP_AUTH_PASSWORD']) if Rails.env.production?

OkComputer::Registry.register "elasticsearch_check",  OkComputer::ElasticsearchCheck.new( URI.parse( ENV['SEARCHBOX_URL'] || "http://localhost:9200/" ) )
OkComputer::Registry.register "check_elasticsearch",  HealthCheck::Elasticsearch.new
OkComputer::Registry.register "check_redis",          HealthCheck::Redis.new
OkComputer::Registry.register "check_mangopay",       HealthCheck::Mangopay.new
#OkComputer::Registry.register "check_for_odds",       HealthCheck::Random.new

# Known missing checks:
# amazon s3 buckets can be reached
# google geocoder API can be reached
# mandrill email sending

# facebook oauth2
# google oauth2
# spid oauth2

