
class LoginController < ApplicationController
  before_filter :login_required, :only => :logout
  before_filter :not_logged_in_required, :only => :index

  layout 'public'

  MAX_LOGIN_ATTEMPTS, BLOCK_TIME_HOURS = 5, 4

  def index
    logger.debug ':-) login_controller.index'
    login_attempt = LoginAttempt.fetch(request.remote_ip)
    @app_params = AppParam.load
    if login_attempt.blocked?
      logger.debug ":-) login is temporarily blocked for this ip: #{login_attempt.ip}"
      flash.now[:error] = t('temporarily_blocked') unless flash[:notice]
    else
      if request.post?
        u = User.authenticate params[:username], params[:password]
        if u
          logger.debug ':-) user authenticated'
          if u.active?
            logger.debug ':-) user active'
            log_user_in u            
            redirect_back_or_default root_path
          else
            logger.debug ':-o user not active'
            flash.now[:error] = t('account_disabled')
          end
        else
          logger.debug ':-o user not authenticated'
          login_attempt.increment_or_block(MAX_LOGIN_ATTEMPTS, BLOCK_TIME_HOURS)
          note_failed_login login_attempt
        end
      end
    end
  end

  def logout
    logger.debug ':-) login_controller.logout'
    reset_session
    redirect_to login_path
  end

  private

    def note_failed_login(login_attempt)
      if login_attempt.blocked?
        flash.now[:error] = t('blocked', :hours => BLOCK_TIME_HOURS)
      else
        flash.now[:error] = t('invalid_login', :remaining => MAX_LOGIN_ATTEMPTS - login_attempt.attempts_count)
      end
    end

    def log_user_in(u)
      remember_me = params[:remember_me] == '1'
      inactivity_threshold = APP_CONFIG[:user_max_inactivity_minutes].minutes.from_now

      u.log_in(remember_me, inactivity_threshold)
      
      reset_session
      self.current_user = u
      session[:adm_menu] = true if u.admin?

      clear_login_attempts
    end   

    def clear_login_attempts
      LoginAttempt.delete_all_by_ip request.remote_ip
    end
end
