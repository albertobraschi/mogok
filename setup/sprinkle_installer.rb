
# Sprinkle gem script to setup a server (Sprinkle works better with Ubuntu).

# packages
%w(apache essential memcached mysql required_gems ruby_enterprise scm).each do |r|
  require File.join(File.dirname(__FILE__), 'packages', r)
end

policy :passenger_stack, :roles => :app do
  requires :webserver               # apache

  requires :apache_etag_support     # apache extras
  requires :apache_deflate_support   
  requires :apache_expires_support  

  requires :appserver               # passenger
  requires :ruby_enterprise         # ruby enterprise edition
  requires :database                # mysql server
  requires :ruby_database_driver    # mysql driver
  requires :memcached               # memcached
  requires :libmemcached            # libmemcached
  requires :required_gems           # gems required by this app
  # requires :scm                   # Git (only when deploying from remote repository)
end

deployment do  
  # mechanism for deployment
  delivery :capistrano do
    begin
      recipes 'setup/install'
    rescue LoadError
      puts 'Error: cannot find capistrano install recipe.'
    end
  end

  # source based package installer defaults
  source do
    prefix   '/usr/local'
    archives '/usr/local/sources'
    builds   '/usr/local/build'
  end
end



