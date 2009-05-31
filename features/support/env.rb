
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

# webrat
require 'webrat'
Webrat.configure do |config|
  config.mode = :rails
end

# support files dir
support_files_dir = File.expand_path(File.join(File.dirname(__FILE__), '../../spec/support'))

# machinist
require 'machinist'
blueprints_dir = File.join(support_files_dir, 'blueprints')
Dir.glob(File.join(blueprints_dir, '*.rb')).each {|f| require f }

# force default locale to 'en' as tests use interface messages
I18n.default_locale = 'en'

# test data directory
TEST_DATA_DIR = File.join(support_files_dir, 'test_data')

# fetchers, makers and finders
['fetchers.rb', 'makers.rb', 'finders.rb'].each {|f| require File.join(support_files_dir, f)}


# stdout logging
LOG_TO_STDOUT = false # set to true to log to the console (messy but useful in some cases)
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

puts "> CACHE_ENABLED       = #{CACHE_ENABLED}"
puts "> I18n.default_locale = #{I18n.default_locale}"
puts "> Support directory   = #{support_files_dir}"
puts "> Test data directory = #{TEST_DATA_DIR}"
puts "> Blueprints directory = #{blueprints_dir}"


