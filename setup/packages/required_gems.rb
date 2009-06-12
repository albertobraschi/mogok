
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
  requires :whenever
end

package :cache_money do
  description 'Cache Money Gem'
  gem 'nkallen-cache-money' do
    source 'http://gems.github.com'
  end
  version '0.2.5'

  verify do
    has_gem 'nkallen-cache-money'
  end

  requires :memcache_client
end

package :cucumber do
  description 'Cucumber Gem'
  gem 'cucumber' do
    post :install, 'ln -s /usr/local/ruby-enterprise/bin/cucumber /usr/local/bin/cucumber'
  end
  version '0.3.1'  

  verify do
    has_gem 'cucumber'
    has_file '/usr/local/ruby-enterprise/bin/cucumber'
    has_symlink '/usr/local/bin/cucumber', '/usr/local/ruby-enterprise/bin/cucumber'
  end
end

package :machinist do
  description 'Machinist Gem'
  gem 'notahat-machinist' do
    source 'http://gems.github.com'
  end
  version '0.3.1'

  verify do
    has_gem 'notahat-machinist'
  end
end

package :memcache_client do
  description 'Memcache Client Gem'
  gem 'memcache-client'
  version '1.7.2'

  verify do
    has_gem 'memcache-client'
  end  
end

package :rspec do
  description 'Rspec Gem'
  gem 'rspec' do
    post :install, 'ln -s /usr/local/ruby-enterprise/bin/spec /usr/local/bin/spec'
  end
  version '1.2.6'  

  verify do
    has_gem 'rspec'
    has_file '/usr/local/ruby-enterprise/bin/spec'
    has_symlink '/usr/local/bin/spec', '/usr/local/ruby-enterprise/bin/spec'
  end
end

package :rspec_rails do
  description 'Rspec Rails Gem'
  gem 'rspec-rails'
  version '1.2.6'

  verify do
    has_gem 'rspec-rails'
  end
end

package :ruby_debug do
  description 'Ruby Debug Gem'
  gem 'ruby-debug'
  version '0.10.3'

  verify do
    has_gem 'ruby-debug'
  end
end

package :system_timer do
  description 'SystemTimer Gem'
  gem 'SystemTimer'
  version '1.1.1'

  verify do
    has_gem 'SystemTimer'
  end
end

package :webrat do
  description 'Webrat Gem'
  gem 'webrat'
  version '0.4.4'

  verify do
    has_gem 'webrat'
  end

  requires :webrat_dependencies
end

package :whenever do
  description 'Whenever Gem'
  gem 'javan-whenever' do
    source 'http://gems.github.com'
    post :install, 'ln -s /usr/local/ruby-enterprise/bin/whenever /usr/local/bin/whenever'
  end
  version '0.3.0'  

  verify do
    has_gem 'webrat'
    has_file '/usr/local/ruby-enterprise/bin/whenever'
    has_symlink '/usr/local/bin/whenever', '/usr/local/ruby-enterprise/bin/whenever'
  end

  requires :chronic # it should install the dependencies, but it doesn't...
end

# dependencies

  package :chronic do
    description 'Chronic Gem'
    gem 'chronic'
    version '0.2.3'

    verify do
      has_gem 'chronic'
    end
  end

  package :webrat_dependencies do
    description 'Libraries required by the Webrat gem'
    apt %w( libxml2 libxml2-dev libxslt1.1 libxslt1-dev libxml-ruby libxslt-ruby )
  end



