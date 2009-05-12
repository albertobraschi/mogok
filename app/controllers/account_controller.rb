
class AccountController < ApplicationController  
  before_filter :login_required, :only => :logout
  before_filter :not_logged_in_required, :only => [:login, :signup, :password_recovery, :change_password]

  before_filter :set_mailer_host, :only => :password_recovery
  
  layout 'public'

  MAX_LOGIN_ATTEMPTS, BLOCK_TIME_HOURS = 5, 4

  def login
    logger.debug ':-) account_controller.login'
    login_attempt = LoginAttempt.fetch(request.remote_ip)
    @app_params = AppParam.load
    if login_attempt.blocked?
      logger.debug ":-) login is temporarily blocked for this ip: #{login_attempt.ip}"
      flash.now[:error] = t('temporarily_blocked') unless flash[:notice]
    else      
      if request.post?
        logger.debug ':-) post request'
        u = User.authenticate params[:username], params[:password]
        if u
          logger.debug ':-) user authenticated'
          if u.active?
            logger.debug ':-) user active'
            log_user_in u, params[:stay_logged_in] == '1'
            clean_login_attempts
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
    logger.debug ':-) account_controller.logout'
    reset_session
    redirect_to :action => 'login'
  end
  
  def signup    
    logger.debug ':-) account_controller.signup'
    @app_params = AppParam.load
    if signup_open? && signup_not_blocked?
      @user = User.new params[:user]
      unless request.post?
        if params[:invite_code]
          i = Invitation.find_by_code params[:invite_code]
          if i
            @user.email = i.email
          else
            if @app_params[:signup_by_invitation_only]
              @user.add_error :invite_code, 'invalid'
            else
              params[:invite_code] = nil # if code invalid but not required
            end
          end
        end
      else
        logger.debug ':-) post request'
        if save_new_user
          SignupBlock.create(:ip => request.remote_ip, :blocked_until => 1.day.from_now)
          log_user_in
          redirect_to root_path
        else
          logger.debug ':-o user data invalid'
          @user.password = @user.password_confirmation = ''
        end
      end
    else
      redirect_to login_path
    end
  end
  
  def password_recovery
    logger.debug ':-) account_controller.password_recovery'
    if request.post?
      user = User.find_by_email params[:email]
      if user && user.active?
        code = user.create_password_recovery
        begin
          AppMailer.deliver_password_recovery user, code
          flash[:notice] = t('success', :email => user.email)
        rescue => e
          log_error e
          PasswordRecovery.delete_all_by_user user
          flash.now[:error] = t('delivery_error')
        end
        redirect_to :action => 'login'
      else
        params[:email] = HtmlHelper.sanitize params[:email]
        flash.now[:error] = t('invalid_email', :email => params[:email])
      end
    end
  end

  def change_password
    logger.debug ':-) account_controller.change_password'
    password_recovery = PasswordRecovery.find_by_code params[:recovery_code]
    if password_recovery
      logger.debug ':-) password_recovery found'
      @user = password_recovery.user
      if request.post?
        unless params[:password].blank?
          logger.debug ':-) post request'
          if @user.change_password(params[:password], params[:password_confirmation])
            logger.debug ':-) user password changed'            
            password_recovery.destroy
            clean_login_attempts
            flash[:notice] = t('success')
            redirect_to :action => 'login', :username => @user.username
          else
            logger.debug ':-o user password not changed'
          end
        else
          @user.add_error :password, 'required'
        end
      end
    else
      logger.debug ':-o invalid recovery code'
      flash[:error] = t('invalid_code')
      redirect_to login_path
    end
  end

  private

  def set_login_failed_message(login_attempt)
    if login_attempt.blocked?
      flash.now[:error] = t('blocked', :hours => BLOCK_TIME_HOURS)
    else
      flash.now[:error] = t('invalid_login', :remaining => MAX_LOGIN_ATTEMPTS - login_attempt.attempts_count)
    end
  end

  def log_user_in(u = nil, keep_logged_in = false)
    u ||= @user
    u.log_in keep_logged_in, APP_CONFIG[:user_max_inactivity_minutes].minutes.from_now
    logger.debug ":-) user token expires at: #{u.token_expires_at}"
    reset_session
    session[:user_id], session[:token] = u.id, u.token
    session[:adm_menu] = true if u.admin?
  end

  def signup_open?
    unless @app_params[:signup_open]
      logger.debug ':-) signup is closed'
      flash[:error] = t('closed')      
      return false
    end
    true
  end

  def signup_not_blocked?
    signup_block = SignupBlock.find_by_ip request.remote_ip
    if signup_block && signup_block.blocked?
      logger.debug ":-) signup temporarily blocked for this ip: #{signup_block.ip}"
      flash[:error] = t('blocked')
      return false
    end
    true
  end

  def save_new_user
    @user.save_with_invite params[:invite_code], @app_params[:signup_by_invitation_only]
  end

  def clean_login_attempts
    LoginAttempt.delete_all_by_ip request.remote_ip
  end
  
  def set_mailer_host
    AppMailer.default_url_options[:host] = request.host_with_port
  end
end
