
module CachingMethods

  def expire_cached(key)
    CACHE.delete key if CACHE_ENABLED
  end

  def fetch_cached(key)
    if CACHE_ENABLED
      CACHE.fetch(key) { yield }
    else
      yield
    end
  end
end