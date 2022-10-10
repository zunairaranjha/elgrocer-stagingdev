Geocoder.configure(
  # :timeout => 30,
  # :api_key => ENV['GOOGLE_MAPS_KEY'],
  # :use_https => true,
  # cache: Rails.cache

  # geocoding options
 :timeout      => 30,           # geocoding service timeout (secs)
 :lookup       => :google,     # name of geocoding service (symbol)
 :language     => :en,         # ISO-639 language code
 :use_https    => true,        # use HTTPS for lookup requests? (if supported)
 :http_proxy   => '',          # HTTP proxy server (user:pass@host:port)
 :https_proxy  => '',          # HTTPS proxy server (user:pass@host:port)
 :api_key      => ENV['GOOGLE_MAPS_KEY'],         # API key for geocoding service
 :cache        => Rails.cache,         # cache object (must respond to #[], #[]=, and #keys)
 :cache_prefix => "geocoder:" # prefix (string) to use for all cache keys

 # IP address geocoding service (see below for supported options):
 #:ip_lookup => :maxmind,

 # to use an API key:
 #:api_key => "...",

 # exceptions that should not be rescued by default
 # (if you want to implement custom error handling);
 # supports SocketError and TimeoutError
 # :always_raise => [],

 # calculation options
 # :units     => :mi,       # :km for kilometers or :mi for miles
 # :distances => :linear    # :spherical or :linear

)