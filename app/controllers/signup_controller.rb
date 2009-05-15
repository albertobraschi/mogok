
class SignupController < ApplicationController
  before_filter :not_logged_in_required, :only => :index

  layout 'public'

  def index
    logger.debug ':-) signup_controller.index'
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
        if save_new_user
          SignupBlock.create request.remote_ip, 1.day.from_now
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

  private

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
      @user.save_new_with_invite params[:invite_code], @app_params[:signup_by_invitation_only]
    end

    def log_user_in      
      @user.log_in false, APP_CONFIG[:user_max_inactivity_minutes].minutes.from_now
      logger.debug ":-) user token expires at: #{@user.remember_token_expires_at}"
      reset_session
      session[:user_id], session[:remember_token] = @user.id, @user.remember_token
      session[:adm_menu] = @user.admin?
    end
end
