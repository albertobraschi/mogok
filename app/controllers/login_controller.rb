
class LoginController < ApplicationController
  before_filter :logged_in_required, :only => :logout
  before_filter :not_logged_in_required, :only => :login

  layout 'public'

  def login
    logger.debug ':-) login_controller.login'
    login_attempt = LoginAttempt.find_or_create(request.remote_ip)
    @app_params = AppParam.params_hash
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
            log_user_in(u, params[:remember_me] == '1')
            redirect_back_or_default root_path
          else
            logger.debug ':-o user not active'
            flash.now[:error] = t('account_disabled')
          end
        else
          logger.debug ':-o user not authenticated'
          login_attempt.increment_or_block(APP_CONFIG[:login][:max_attempts], APP_CONFIG[:login][:block_hours])
          note_failed_login login_attempt
        end
      end
    end
  end

  def logout
    logger.debug ':-) login_controller.logout'
    logout_killing_session!
    redirect_to login_path
  end

  private

    def log_user_in(user, remember_me)
      user.update_attribute(:last_login_at, Time.now)
      
      self.current_user = user
      handle_remember_cookie!(remember_me)

      session[:adm_menu] = user.admin?
      clear_login_attempts
    end   

    def note_failed_login(login_attempt)
      if login_attempt.blocked?
        flash.now[:error] = t('blocked', :hours => APP_CONFIG[:login][:block_hours])
      else
        flash.now[:error] = t('invalid_login', :remaining => APP_CONFIG[:login][:max_attempts] - login_attempt.attempts_count)
      end
    end

    def clear_login_attempts
      LoginAttempt.delete_all_by_ip request.remote_ip
    end
end
