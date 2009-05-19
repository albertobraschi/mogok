
class AdmController < ApplicationController
  before_filter :logged_in_required
  before_filter :admin_required

  def env
    logger.debug ':-) adm_controller.env'
    if defined?(PhusionPassenger)
      @show_passenger_restart_link = !Rails.env.production || APP_CONFIG[:adm][:passenger_restart_production]
    end
    @show_sensitive = !Rails.env.production? || APP_CONFIG[:adm][:display_env_info_production]
    @env = env_properties
  end

  def switch_menu
    logger.debug ':-) adm_controller.switch_menu'
    if session[:adm_menu]
      session[:adm_menu] = nil
      redirect_to root_path
    else
      session[:adm_menu] = true
      redirect_to :action => 'env'
    end
  end

  def switch_domain_menu
    logger.debug ':-) adm_controller.switch_domain_menu'
    if session[:adm_domain_menu]
      session[:adm_domain_menu] = nil
      redirect_to :action => 'env'
    else
      session[:adm_domain_menu] = true
      redirect_to :controller => 'categories'
    end
  end

  def restart_passenger
    logger.debug ':-) adm_controller.restart_passenger'
    access_denied if Rails.env.production? && !APP_CONFIG[:adm][:passenger_restart_production]
    if request.post?
      %x{touch #{File.join(RAILS_ROOT, 'tmp/restart.txt')}}
    end
    redirect_to :action => 'env'
  end

  private

    def env_properties
      h = {}

      h[:server_hostname] = %x{uname -a}

      h[:ruby_version] = "#{RUBY_VERSION} (#{RUBY_PLATFORM})"
      h[:ruby_gems_version] = Gem::RubyGemsVersion

      if defined? PhusionPassenger
        h[:passenger_version] = PhusionPassenger::VERSION_STRING        
      end

      h[:rack_version] = ::Rack.release

      h[:rails_version] = Rails.version
      h[:rails_env] = Rails.env

      db = ActiveRecord::Base.configurations[Rails.env]
      h[:database] = "#{db['database']} (#{db['adapter']})"

      h[:rails_root] = Rails.root
      h[:public_path] = Rails.public_path

      logger_level = Rails.logger.level
      h[:logger_level] = "#{logger_level} (#{logger_level_description logger_level})"

      h[:locale] = I18n.locale

      if CACHE_ENABLED
        unless CACHE.servers.blank?
          a = []
          CACHE.servers.each do |s|
            h = {}
            h[:host] = s.host
            h[:port] = s.port
            h[:status] = s.status
            h[:stats] = CACHE.stats["#{s.host}:#{s.port}"].symbolize_keys!
            a << h
          end
          h[:memcached_servers] = a
        end
      end
      h
    end

    def logger_level_description(level)
      (0..5).include?(level) ? ['debug', 'info', 'warn', 'error', 'fatal', 'unknown'][level] : '????'
    end
end











