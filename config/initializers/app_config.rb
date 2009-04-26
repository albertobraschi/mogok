require 'yaml'

# application config (used throughout the app)
APP_CONFIG = open(File.join(RAILS_ROOT, 'config/app_config.yml')) {|f| YAML.load(f) }
APP_CONFIG.symbolize_keys!

APP_CONFIG[:started_at] = Time.now

APP_CONFIG.freeze

# default locale
I18n.default_locale = APP_CONFIG[:default_locale]

# using mogok custom will_paginate links renderer (delete this line to use the original)
WillPaginate::ViewHelpers.pagination_options[:renderer] = WillPaginate::MogokLinkRenderer

# logger config
RAILS_DEFAULT_LOGGER.level = RAILS_ENV == 'production' ? Logger::ERROR : Logger::DEBUG

# get rid of the red divs in the invalid form fields
ActionView::Base.field_error_proc = Proc.new {|html_tag, instance| "#{html_tag}" }

# set session expiration (do not confuse with user token expiration)
ActionController::Base.session_options[:expire_after] = 1.year




  
