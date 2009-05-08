
if CACHE_ENABLED
  require 'memcache'
  memcached_config = open(File.join(RAILS_ROOT, 'config/memcached.yml')) {|f| YAML.load(f)[Rails.env] }
  memcached_config.symbolize_keys!
  memcached_config[:logger] = RAILS_DEFAULT_LOGGER

  # rails cache store
    ActionController::Base.cache_store = :mem_cache_store, memcached_config[:servers], memcached_config

  # application cache
    CACHE = MemCache.new memcached_config
    CACHE.servers = memcached_config[:servers]

    # patch to avoid memcached connections conflict between processes when using passenger
    if defined?(PhusionPassenger)
      PhusionPassenger.on_event(:starting_worker_process) do |forked|
        CACHE.reset if forked # we're in smart spawning mode, reset connection
      end
    end

  # cache_money
    require 'cache_money'

    $local = Cash::Local.new(CACHE)
    $lock = Cash::Lock.new(CACHE)
    $cache = Cash::Transactional.new($local, $lock)

    class ActiveRecord::Base
      is_cached :repository => $cache
    end
else  
  class ActiveRecord::Base
    def self.index(*args)
      # cache_money disabled
    end
  end
end

