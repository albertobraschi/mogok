
module ErrorHandling

  protected
  
    def handle_error(e)
      logger.debug ':-o error_handling.handle_error'

      layout = 'public' unless current_user # also set logged user if necessary

      if e.is_a? ActionController::InvalidAuthenticityToken
        log_error e
        redirect_to root_path
      else
        case e
          when ActiveRecord::RecordNotFound
            template = 'invalid_request'
          when ArgumentError
            template = 'invalid_request'
          when ActionController::RoutingError
            template = 'invalid_route'
          when ActionController::UnknownAction
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
        m =  "Error: #{e.class}\n"
        m << "Page: #{template}\n" if template
        m << "Message: #{e.clean_message}"

        l = clean_backtrace(e)[0, 15].join("\n")

        ErrorLog.create :created_at => Time.now, :message => m, :location => l
      end
    end
end


