
module AppAuthorization

  protected

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
      raise AccessDeniedError
    end
end




