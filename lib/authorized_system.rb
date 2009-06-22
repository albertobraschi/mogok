
class AccessDeniedError < StandardError
end

module AuthorizedSystem

  protected

    def logged_in_required
      logger.debug ':-) app_authorization.logged_in_required'
      if logged_in?
        logger.debug ':-) user logged in'
        after_logged_in_required # callback
      else
        logger.debug ':-o user not logged in, redirecting to login page'
        logout_killing_session!
        store_location
        redirect_to login_path
      end
    end

    def not_logged_in_required
      logger.debug ':-) app_authorization.not_logged_in_required'
      if logged_in?
        redirect_to root_path
      end
    end

    def ticket_required(ticket)
      logger.debug ':-) app_authorization.ticket_required'
      access_denied unless current_user.has_ticket? ticket
    end

    def owner_required
      logger.debug ':-) app_authorization.owner_required'
      access_denied unless current_user.owner?
    end

    def admin_required
      logger.debug ':-) app_authorization.admin_required'
      access_denied unless current_user.admin?
    end

    def admin_mod_required
      logger.debug ':-) app_authorization.admin_mod_required'
      access_denied unless current_user.admin_mod?
    end

    def access_denied
      logger.debug ':-o app_authorization.access_denied'
      raise AccessDeniedError
    end
    
    def after_logged_in_required
      # callback called by logged_in_required, overwrite in your controller if needed
    end
end




