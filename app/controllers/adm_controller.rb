
class AdmController < ApplicationController
  before_filter :login_required
  before_filter :admin_required, :only => [:env, :switch_menu, :switch_domain_menu]
  before_filter :owner_required, :only => :passenger_restart

  def env
    logger.debug ':-) adm_controller.env'
    @server_hostname = %x{uname -a}
    @on_passenger = defined? PhusionPassenger
    if CACHE_ENABLED
      unless CACHE.servers.blank?
        @memcached_servers = []
        CACHE.servers.each do |s|
          h = {}
          h[:host] = s.host
          h[:port] = s.port
          h[:status] = s.status
          h[:stats] = CACHE.stats["#{s.host}:#{s.port}"].symbolize_keys!
          @memcached_servers << h
        end
      end      
    end
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

  def passenger_restart
    logger.debug ':-) adm_controller.passenger_restart'
    if request.post?
      %x{touch #{File.join(RAILS_ROOT, 'tmp/restart.txt')}}
    end
    redirect_to :action => 'env'
  end
end