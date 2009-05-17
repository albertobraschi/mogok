require 'yaml'

# application config (used throughout the app)
APP_CONFIG = open(File.join(RAILS_ROOT, 'config/app_config.yml')) {|f| YAML.load(f) }
APP_CONFIG.keys.each {|k| APP_CONFIG[k].symbolize_keys! if APP_CONFIG[k].is_a? Hash } # symbolize the inner hashs
APP_CONFIG.symbolize_keys!
APP_CONFIG.freeze

# default locale
I18n.default_locale = APP_CONFIG[:default_locale]

# using mogok custom will_paginate links renderer (delete this line to use the original)
WillPaginate::ViewHelpers.pagination_options[:renderer] = WillPaginate::MogokLinkRenderer

# logger config
Rails.logger.level = Rails.env.production? ? Logger::ERROR : Logger::DEBUG

# get rid of the red divs in the invalid form fields
ActionView::Base.field_error_proc = Proc.new {|html_tag, instance| "#{html_tag}" }
