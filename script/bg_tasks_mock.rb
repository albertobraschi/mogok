#!/usr/bin/env ruby

require 'rubygems'
require 'logger'

RAILS_ENV = ARGV[0] || 'development'

logger = RAILS_DEFAULT_LOGGER = Logger.new($stdout)

require File.join(File.dirname(__FILE__), '../config/environment.rb')

logger.debug ":-) bg_tasks_mock started - RAILS_ENV: #{RAILS_ENV}"

loop do
  puts
  puts
  logger.debug ':-) bg_tasks_mock awake'
  logger.debug ":-) executing at #{Time.now}"

  BgTasks::Dispatcher.exec APP_CONFIG, logger, RAILS_ENV
  
  logger.debug ':-) bg_tasks_mock going asleep'
  puts
  puts
  sleep 70
end
