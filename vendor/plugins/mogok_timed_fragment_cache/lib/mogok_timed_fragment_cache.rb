
module ActionController
  
  module Caching
 
    module MogokTimedFragment

      EXPIRATION_KEY_SUFFIX = '_expiration'

      def expire_timed_fragment(name, force = false)
        expiration = read_fragment_expiration(name)
        if expiration.nil?
          return true
        elsif expiration < Time.now || force
          expire_fragment fragment_expiration_key(name)
          expire_fragment name          
          return true
        end
        false
      end

      def fragment_expired?(name)
        expiration = read_fragment_expiration(name)
        if expiration.nil? || expiration < Time.now
          return true 
        end
        false
      end

      def read_fragment_expiration(name)
        YAML.load(read_fragment(fragment_expiration_key(name))) rescue nil
      end

      def write_fragment_expiration(name, expires_at)
        write_fragment fragment_expiration_key(name), YAML.dump(expires_at)
      end

      def fragment_expiration_key(name)
        "#{name}#{EXPIRATION_KEY_SUFFIX}"
      end
    end
  end
end

module ActionView
  module Helpers
    module MogokTimedFragmentCacheHelper
    
      def self.included(base) # :nodoc:     
        base.class_eval do 
          alias_method :cache_without_expiration, :cache
          alias_method :cache, :cache_with_expiration
        end      
      end    
    
      def cache_with_expiration(name = {}, expires = nil, &block)
        if expires && @controller.fragment_expired?(name)
          @controller.write_fragment_expiration(name, expires) if expires
        end
        cache_without_expiration(name, &block)
      end    
    end
  end
end

ActionController::Base.send :include, ActionController::Caching::MogokTimedFragment

ActionController::Caching::Sweeper.send :include, ActionController::Caching::MogokTimedFragment

ActionView::Base.send :include, ActionView::Helpers::MogokTimedFragmentCacheHelper


