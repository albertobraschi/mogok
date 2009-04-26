
class AccountController < ApplicationController
  before_filter :set_mailer_host, :only => :password_recovery
  before_filter :login_required, :only => :logout
  before_filter :not_logged_in_required, :only => [:login, :signup, :password_recovery, :change_password]
  layout 'public'

  MAX_LOGIN_ATTEMPTS, BLOCK_TIME_HOURS = 5, 4

  def login
    logger.debug ':-) account_controller.login'
    login_attempt = LoginAttempt.find_by_ip request.remote_ip
    if login_attempt && login_attempt.blocked?
      logger.debug ":-) login is temporarily blocked for this ip: #{login_attempt.ip}"
      flash.now[:error] = t('controller.account.login.blocked')
    else
      if request.post?
        logger.debug ':-) post request'
        u = User.authenticate params[:username], params[:password]
        if u
          logger.debug ':-) user authenticated'
          if u.active?
            logger.debug ':-) user active'
            u.last_login_at = Time.now
            u.reset_token # prevents multiple logins
            u.token_expires_at = (params[:stay_logged_in] == '1') ? 10.days.from_now : APP_CONFIG[:user_max_inactivity_minutes].minutes.from_now
            logger.debug ":-) user token expires at: #{u.token_expires_at}"
            u.save
            log_user_in u
            clean_login_attempts                        
            uri, session[:original_uri] = session[:original_uri], nil
            redirect_to uri || {:controller => 'content'}
          else
            logger.debug ':-o user not active'
            flash.now[:error] = flash.now[:error] = t('controller.account.login.account_disabled')
          end
        else
          logger.debug ':-o user not authenticated'
          check_login_attempts login_attempt
        end
      end
      params[:password] = nil
    end
  end

  def logout
    logger.debug ':-) account_controller.logout'
    reset_session
    redirect_to :action => 'login'
  end
  
  def signup    
    logger.debug ':-) account_controller.signup'
    signup_block = SignupBlock.find_by_ip request.remote_ip
    if signup_block && signup_block.still_blocked?
      logger.debug ":-) signup is temporarily blocked for this ip: #{signup_block.ip}"
      flash[:error] = t('controller.account.signup.blocked')
      redirect_to :action => 'login'
    else
      @app_params = AppParam.load
      @user = User.new params[:user]
      if request.post?
        logger.debug ':-) post request'
        access_denied unless @app_params[:signup_open]
        if save_new_user @user, @app_params[:signup_by_invitation_only]
          SignupBlock.create :ip => request.remote_ip, :blocked_until => 1.day.from_now
          log_user_in @user
          redirect_to root_path
        else
          logger.error ':-o user data invalid'
          @user.password = @user.password_confirmation = ''
        end
      end
    end
  end
  
  def password_recovery
    logger.debug ':-) account_controller.password_recovery'
    if request.post?
      user = User.find_by_email params[:email] if User.valid_email? params[:email]
      if user && user.active?
        begin
          code = User.make_password_recovery_code
          AppMailer.deliver_password_recovery user, code
          PasswordRecovery.delete_all ['user_id = ?', user.id] # if user already have one
          PasswordRecovery.create :created_at => Time.now, :code => code, :user_id => user.id
          flash[:notice] = t('controller.account.password_recovery.sent', :email => user.email)
        rescue => e
          log_error e
          flash.now[:error] = t('controller.account.password_recovery.delivery_error')
        end
        redirect_to :action => 'login'
      else
        params[:email] = HtmlHelper.sanitize params[:email]
        flash.now[:error] = t('controller.account.password_recovery.invalid_email', :email => params[:email])
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
          @user.password, @user.password_confirmation = params[:password], params[:password_confirmation]
          if @user.save
            logger.debug ':-) user saved'
            flash[:notice] = t('controller.account.change_password.changed')
            password_recovery.destroy
            clean_login_attempts
            redirect_to :action => 'login', :username => @user.username
          else
            logger.debug ':-o user not saved'
          end
        else
          @user.errors.add :password, t('model.user.password.required')
        end
      end
    else
      logger.debug ':-o invalid recovery code'
      flash[:error] = t('controller.account.change_password.invalid_link')
      redirect_to :action => 'login'
    end
  end

  private

  def log_user_in(u)
    reset_session
    session[:user_id] = u.id
    session[:token] = u.token
    session[:adm_menu] = true if u.admin?
  end

  def check_login_attempts(a)
    unless a
      a = LoginAttempt.create :ip => request.remote_ip, :attempts_count => 1
    else
      if a.attempts_count < (MAX_LOGIN_ATTEMPTS - 1)
        a.attempts_count += 1        
      else
        a.blocked_until = BLOCK_TIME_HOURS.hours.from_now
        a.attempts_count = 0        
        register_login_block a.ip
      end
      a.save
    end
    if a.blocked?
      flash.now[:error] = t('controller.account.check_login_attempts.blocked', :hours => BLOCK_TIME_HOURS)
    else
      flash.now[:error] = t('controller.account.check_login_attempts.invalid_login', :remaining => MAX_LOGIN_ATTEMPTS - a.attempts_count)
    end
  end

  def register_login_block(ip)
    b = LoginBlock.find_by_ip ip
    unless b
      LoginBlock.create :ip => ip, :blocks_count => 1
    else
      b.increment! :blocks_count
    end
  end

  def save_new_user(u, invite_required)    
    i = Invitation.find_by_code params[:invite_code] if params[:invite_code]
    unless i
      if invite_required
        u.errors.add :invite_code, t('model.user.invite_code.invalid')
        return false
      end
    else
      u.inviter_id = i.user_id
      u.email = i.email
      logger.debug ":-) inviter id: #{u.inviter_id}"    
    end
    set_new_user u
    if u.save
      logger.debug ":-) user created. id: #{u.id}"
      i.destroy if i
      return true
    end
    false
  end

  def set_new_user(u)
    u.role = Role.find_by_name Role::USER
    u.created_at = Time.now
    u.reset_token
    u.token_expires_at = APP_CONFIG[:user_max_inactivity_minutes].minutes.from_now
    u.reset_passkey
    u.avatar = APP_CONFIG[:default_avatar]
    u.style = Style.find :first
  end

  def clean_login_attempts
    LoginAttempt.delete_all ['ip = ?', request.remote_ip]
  end
  
  def set_mailer_host
    AppMailer.default_url_options[:host] = request.host_with_port
  end
end
