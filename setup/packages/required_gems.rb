
package :required_gems do
  description 'Gems required by the application'
  requires :cache_money
  requires :cucumber
  requires :machinist
  requires :memcache_client
  requires :rspec
  requires :rspec_rails  
  requires :ruby_debug
  requires :system_timer
  requires :webrat  
end

package :cache_money do
  description 'Cache Money Gem'
  gem 'nkallen-cache-money' do
    source 'http://gems.github.com'
  end
  version '0.2.5'
  requires :memcache_client
end

package :system_timer do
  description 'SystemTimer Gem'
  gem 'SystemTimer'
  version '1.1.1'
end

package :memcache_client do
  description 'Memcache Client Gem'
  gem 'memcache-client'
  version '1.7.2'
end

package :ruby_debug do
  description 'Ruby Debug Gem'
  gem 'ruby-debug'
  version '0.10.3'
end

package :rspec do
  description 'Rspec Gem'
  gem 'rspec'
  version '1.2.6'
end

package :rspec_rails do
  description 'Rspec Rails Gem'
  gem 'rspec-rails'
  version '1.2.6'
end

package :cucumber do
  description 'Cucumber Gem'
  gem 'cucumber'
  version '0.3.1'
end

package :webrat do
  description 'Webrat Gem'
  gem 'webrat'
  version '0.4.4'
  requires :webrat_dependencies
end

package :machinist do
  description 'Machinist Gem'
  gem 'notahat-machinist' do
    source 'http://gems.github.com'
  end
  version '0.3.1'
end

package :whenever do
  description 'Whenever Gem'
  gem 'javan-whenever' do
    source 'http://gems.github.com'
  end
  version '0.2.2'
end


package :webrat_dependencies do
  description 'Libraries required by the Webrat gem'
  apt %w( libxml2 libxml2-dev libxslt1.1 libxslt1-dev libxml-ruby libxslt-ruby )
end
