# *** restart your server when you modify this file ***

# specifies gem version of rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# bootstrap the rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')


# enables caching in development (more logs are shown but requires restart after any change in the app)
#cache_in_development = true
cache_in_development = false

CACHE_ENABLED = (RAILS_ENV == 'production') || (RAILS_ENV == 'test') || cache_in_development


Rails::Initializer.run do |config|
  
  # cache store
  if CACHE_ENABLED
    memcached_config = open(File.join(RAILS_ROOT, 'config/memcached.yml')) {|f| YAML.load(f)[RAILS_ENV] }
    config.cache_store = :mem_cache_store, memcached_config['servers'], memcached_config
  end
  
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  config.load_paths += ["#{RAILS_ROOT}/app/sweepers"]

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  # config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql
end







