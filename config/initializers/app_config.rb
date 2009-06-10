require 'yaml'

# extension to allow recursive key symbolization
class Hash
  def recursive_symbolize_keys!
    symbolize_keys!
    values.select {|v| v.is_a?(Hash) }.each {|h| h.recursive_symbolize_keys! }
  end
end

# application config (used throughout the app)
APP_CONFIG = open(File.join(RAILS_ROOT, 'config/app_config.yml')) {|f| YAML.load(f)[Rails.env] }
APP_CONFIG.recursive_symbolize_keys!
APP_CONFIG.freeze if Rails.env.production?

# default locale
I18n.default_locale = APP_CONFIG[:default_locale]

# using mogok custom will_paginate links renderer (delete this line to use the original)
WillPaginate::ViewHelpers.pagination_options[:renderer] = WillPaginate::MogokLinkRenderer

# logger config
Rails.logger.level = Rails.env.production? ? Logger::ERROR : Logger::DEBUG

# get rid of the red divs in the invalid form fields
ActionView::Base.field_error_proc = Proc.new {|html_tag, instance| "#{html_tag}" }
