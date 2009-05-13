
module AccessControl

  protected
  
  def logged_user
    @logged_user || set_logged_user
  end

  def set_logged_user
    logger.debug ':-) access_control.set_logged_user'
    logger.debug ":-) session[user_id]: #{session[:user_id]} - session[token]: #{session[:token]}"
    u = User.find_by_id session[:user_id]
    if u && u.active? && u.token == session[:token] && u.token_expires_at > Time.now
      logger.debug ":-) user is logged in: #{u.username}"
      u.register_access(APP_CONFIG[:user_max_inactivity_minutes].minutes.from_now)
      @logged_user = u      
    else
      unless u
        logger.debug ":-o user not found for id: #{session[:user_id]}"
      else
        logger.debug ':-) user is inactive' if !u.active?
        logger.debug ':-o user token is invalid' if u.token != session[:token]
        logger.debug ':-o user token is expired' if u.token_expires_at && u.token_expires_at < Time.now
      end
      return nil
    end
  end

  def login_required
    logger.debug ':-) access_control.login_required'
    unless logged_user
      logger.debug ':-) not logged in, redirecting to login page'
      reset_session
      session[:original_uri] = request.request_uri
      redirect_to login_path
    else
      after_login_required
    end    
  end

  def after_login_required
    # overwrite this method for additional processing
  end

  def not_logged_in_required
    logger.debug ':-) access_control.not_logged_in_required'
    if session[:user_id] && logged_user
      redirect_to root_path
    end
  end

  def ticket_required(ticket)
    logger.debug ':-) access_control.ticket_required'
    access_denied unless logged_user.has_ticket? ticket
  end

  def owner_required
    logger.debug ':-) access_control.owner_required'
    access_denied unless logged_user.owner?
  end

  def admin_required
    logger.debug ':-) access_control.admin_required'
    access_denied unless logged_user.admin?
  end

  def admin_mod_required
    logger.debug ':-) access_control.admin_mod_required'
    access_denied unless logged_user.admin_mod?
  end

  def access_denied
    raise AccessDeniedError
  end
end




