
module Authentication

  protected

    def current_user
      @current_user || set_current_user
    end

    def set_current_user
      logger.debug ':-) access_control.set_current_user'      
      u = User.find_by_id session[:user_id]
      if u && u.active? && u.token == session[:token] && u.token_expires_at > Time.now        
        u.register_access(APP_CONFIG[:user_max_inactivity_minutes].minutes.from_now)
        @current_user = u
      else
        not_logged_in_debug u
        nil
      end
    end

    def logged_in_required
      logger.debug ':-) access_control.logged_in_required'
      unless current_user
        logger.debug ':-o user not logged in, redirecting to login page'
        reset_session
        session[:original_uri] = request.request_uri
        redirect_to login_path
      else
        logger.debug ":-) user is logged in: #{current_user.username}"
        after_logged_in_required
      end
    end

    def after_logged_in_required
      # overwrite this method for additional processing
    end

    def not_logged_in_required
      logger.debug ':-) access_control.not_logged_in_required'
      if current_user
        redirect_to root_path
      end
    end

  private

    def not_logged_in_debug(u)
      logger.debug ":-) session[user_id]: #{session[:user_id]} - session[token]: #{session[:token]}"
      unless u
        logger.debug ':-o user not found'
      else
        logger.debug ':-) user is inactive' if !u.active?
        logger.debug ':-o user token is invalid' if u.token != session[:token]
        logger.debug ':-o user token is expired' if u.token_expires_at && u.token_expires_at < Time.now
      end
    end
end




