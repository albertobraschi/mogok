
module ErrorHandling
  
  protected

    # Direct all exception to the handle_error method.
    def self.included(base)
      base.send :rescue_from, Exception, :with => :handle_error
    end

    # This method will catch exceptions thrown by the application, log them
    # if necessary and render the appropriate error page for the user.
    def handle_error(e)
      logger.debug ':-o error_handling.handle_error'

      layout = 'public' unless current_user # also sets current user if necessary

      if e.is_a? ActionController::InvalidAuthenticityToken
        log_error e
        redirect_to root_path
      else
        case e
          when ArgumentError, ActiveRecord::RecordNotFound
            template = 'invalid_request'
          when ActionController::RoutingError, ActionController::UnknownAction
            template = 'invalid_route'
          when AccessDeniedError
            template = 'access_denied'
          else
            template = 'fatal'
            force_log = true
        end
        log_error e, template, force_log
        render :template => "error/#{template}", :layout => layout
      end
    end

    def log_error(e, template = nil, force = false)
      if !Rails.env.production? || force
        message =  "Error: #{e.class}\n"
        message << "Page: #{template}\n" if template
        message << "Message: #{e.clean_message}"

        location = clean_backtrace(e)[0, 15].join("\n")

        ErrorLog.create message, location
      end
    end
end


