
class LoginController < ApplicationController
  before_filter :logged_in_required, :only => :logout
  before_filter :not_logged_in_required, :only => :login

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
            log_user_in u, params[:stay_logged_in] == '1'
            clear_login_attempts
            uri, session[:original_uri] = session[:original_uri], nil
            redirect_to uri || root_path
          else
            logger.debug ':-o user not active'
            flash.now[:error] = t('account_disabled')
          end
        else
          logger.debug ':-o user not authenticated'
          login_attempt.increment_or_block(MAX_LOGIN_ATTEMPTS, BLOCK_TIME_HOURS)
          set_login_failed_message login_attempt
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

    def set_login_failed_message(login_attempt)
      if login_attempt.blocked?
        flash.now[:error] = t('blocked', :hours => BLOCK_TIME_HOURS)
      else
        flash.now[:error] = t('invalid_login', :remaining => MAX_LOGIN_ATTEMPTS - login_attempt.attempts_count)
      end
    end

    def log_user_in(u, keep_logged_in)
      u.log_in keep_logged_in, APP_CONFIG[:user_max_inactivity_minutes].minutes.from_now
      logger.debug ":-) user token expires at: #{u.token_expires_at}"
      reset_session
      session[:user_id], session[:token] = u.id, u.token
      session[:adm_menu] = true if u.admin?
    end

    def clear_login_attempts
      LoginAttempt.delete_all_by_ip request.remote_ip
    end
end
