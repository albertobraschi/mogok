
# sets up the rails environment for cucumber

ENV['RAILS_ENV'] = 'test'

require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
require 'cucumber/formatters/unicode' # comment out this line if you don't want Cucumber Unicode support
Cucumber::Rails.use_transactional_fixtures

# or webrat can't find it (a bug, apparently)
require 'spec'

# comment out the next two lines if you're not using RSpec's matchers (should / should_not) in your steps
require 'cucumber/rails/rspec'
require 'webrat/rspec-rails'

require 'webrat'
Webrat.configure do |config|
  config.mode = :rails
end

# force default locale as tests use interface messages
I18n.default_locale = 'en'

# app customizations
TEST_DATA_DIR = File.join(RAILS_ROOT, 'features/support/test_data')
LOG_TO_STDOUT = false

if LOG_TO_STDOUT
  ActiveRecord::Base::logger = Logger.new(STDOUT)
  class ApplicationController
    if LOG_TO_STDOUT
      def handle_error(e)
        puts e.message
        e.backtrace.each {|i| puts i }
      end

      def logger
        Logger.new(STDOUT)
      end
    end
  end
end

puts "> CACHE_ENABLED = #{CACHE_ENABLED}"

puts "> I18n.default_locale = #{I18n.default_locale}"




