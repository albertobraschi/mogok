
module AppAuthentication

  protected

    def self.included(base)
      base.send :helper_method, :current_user
      base.send :filter_parameter_logging, :password
    end

    def logged_in?
      !!current_user
    end

    def current_user
      @current_user ||= login_from_session
    end

    def current_user=(u)
      if u
        session[:user_id] = u.id
        session[:remember_token] = u.remember_token
      end
      @current_user = u
    end

    def login_required
      logger.debug ':-) app_authentication.login_required'
      unless logged_in?
        logger.debug ':-o user not logged in, redirecting to login page'
        logout_killing_session!
        store_location
        redirect_to login_path
      else
        logger.debug ':-) user is logged in'
        after_login_required # callback
      end
    end

    def not_logged_in_required
      logger.debug ':-) app_authentication.not_logged_in_required'
      if logged_in?
        redirect_to root_path
      end
    end

    def login_from_session
      if session[:user_id]
        u = User.find_by_id session[:user_id]
        if u && u.logged_in?(session[:remember_token])
          u.register_access(APP_CONFIG[:user_max_inactivity_minutes].minutes.from_now)
          return u
        else
          debug_not_logged_in u
        end
      end
      nil
    end

    def logout_killing_session!
      reset_session
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to session[:return_to] || default
      session[:return_to] = nil
    end

    def after_login_required
      # callback from login_required, overwrite if needed
    end

  private

    def debug_not_logged_in(u)
      logger.debug ":-) session[user_id]: #{session[:user_id]} - session[token]: #{session[:remember_token]}"
      unless u
        logger.debug ':-o user not found'
      else
        logger.debug ':-) user is inactive' if !u.active?
        logger.debug ':-o user token is invalid' if u.remember_token != session[:remember_token]
        logger.debug ':-o user token is expired' if u.remember_token_expires_at && u.remember_token_expires_at < Time.now
      end
    end
end




