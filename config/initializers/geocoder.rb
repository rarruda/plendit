# This class implements a cache with simple delegation to the Redis store, but
# when it creates a key/value pair, it also sends an EXPIRE command with a TTL.
# It should be fairly simple to do the same thing with Memcached.
class AutoexpireCacheRedis
  def initialize(store, ttl = 86400)
    @store = store
    @ttl = ttl
  end

  def [](url)
    @store.get(url)
  end

  def []=(url, value)
    @store.setex(url, @ttl, value)
  end

  def keys
    @store.keys
  end

  def del(url)
    @store.del(url)
  end
end

Geocoder.configure(
  # geocoding options
  # :timeout      => 3,           # geocoding service timeout (secs)
  # :lookup       => :google,     # name of geocoding service (symbol)
  # :language     => :en,         # ISO-639 language code
  # :use_https    => false,       # use HTTPS for lookup requests? (if supported)
  # :http_proxy   => nil,         # HTTP proxy server (user:pass@host:port)
  # :https_proxy  => nil,         # HTTPS proxy server (user:pass@host:port)
  # :api_key      => nil,         # API key for geocoding service
  # :cache        => nil,         # cache object (must respond to #[], #[]=, and #keys)
  # :cache_prefix => "geocoder:", # prefix (string) to use for all cache keys

  :lookup       => :google,       # name of geocoding service (symbol)
  :api_key      => ENV['PCONF_GOOGLE_GEOCODING_KEY'], # API key for geocoding service
  :use_https    => true,          # HTTPS must be enabled when using a google with an API key
  :cache        => AutoexpireCacheRedis.new(REDIS, 1.week.to_i), # cache object (must respond to #[], #[]=, and #keys)
  :cache_prefix => "geocoder:",   # prefix (string) to use for all cache keys


  # exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and TimeoutError
  # :always_raise => [],

  # calculation options
  :units     => :km,       # :km for kilometers or :mi for miles
  # :distances => :linear    # :spherical or :linear
)
