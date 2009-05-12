
class AdmController < ApplicationController
  before_filter :login_required
  before_filter :admin_required

  def env
    logger.debug ':-) adm_controller.env'    
    set_env_properties    
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
    logger.debug ':-) adm_controller.passenger_restart'
    if request.post?
      %x{touch #{File.join(RAILS_ROOT, 'tmp/restart.txt')}}
    end
    redirect_to :action => 'env'
  end

  private

  def set_env_properties
    @env = {}
    
    @env[:server_hostname] = %x{uname -a}

    @env[:ruby_version] = "#{RUBY_VERSION} (#{RUBY_PLATFORM})"
    @env[:ruby_gems_version] = Gem::RubyGemsVersion

    if defined? PhusionPassenger
      @env[:passenger_version] = PhusionPassenger::VERSION_STRING
    end

    @env[:rack_version] = ::Rack.release

    @env[:rails_version] = Rails.version
    @env[:rails_env] = Rails.env
    @env[:database_adapter] = ActiveRecord::Base.configurations[RAILS_ENV]['adapter']
    @env[:rails_root] = Rails.root
    @env[:public_path] = Rails.public_path
    @env[:logger_level] = Rails.logger.level
    
    @env[:locale] = I18n.locale

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
        @env[:memcached_servers] = a
      end
    end
  end
end











