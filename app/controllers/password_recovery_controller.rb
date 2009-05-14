
class PasswordRecoveryController < ApplicationController
  before_filter :not_logged_in_required

  before_filter :set_mailer_host, :only => :index

  layout 'public'

  def index
    logger.debug ':-) password_recovery_controller.index'
    if request.post?
      params[:email] = HtmlHelper.sanitize params[:email]
      u = User.find_by_email params[:email]
      if u && u.active?
        password_recovery = u.create_password_recovery
        begin
          AppMailer.deliver_password_recovery u, password_recovery.code
          flash[:notice] = t('success', :email => u.email)
        rescue => e
          log_error e
          password_recovery.destroy
          flash[:error] = t('delivery_error')
        end
        redirect_to login_path
      else        
        flash.now[:error] = t('invalid_email')
      end
    end
  end

  def change_password
    logger.debug ':-) password_recovery_controller.change_password'
    password_recovery = PasswordRecovery.find_by_code params[:recovery_code]
    if password_recovery
      logger.debug ':-) password_recovery found'
      @user = password_recovery.user
      if request.post?
        if @user.change_password(params[:password], params[:password_confirmation])
          logger.debug ':-) user password changed'
          password_recovery.destroy
          clear_login_attempts
          flash[:notice] = t('success')
          redirect_to login_path(:username => @user.username)
        else
          logger.debug ':-o user password not changed'
        end
      end
    else
      logger.debug ':-o invalid recovery code'
      flash[:error] = t('invalid_code')
      redirect_to login_path
    end
  end

  private

    def clear_login_attempts
      LoginAttempt.delete_all_by_ip request.remote_ip
    end

    def set_mailer_host
      AppMailer.default_url_options[:host] = request.host_with_port
    end
end
