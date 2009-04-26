
module ErrorHandling

  protected
  
  def handle_error(e)
    logger.debug ':-o error_handling.handle_error'

    layout = 'public' unless logged_user # also set logged user if necessary

    if e.is_a? ActionController::InvalidAuthenticityToken
      redirect_to_home(e)
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

  def redirect_to_home(e)
    log_error e
    redirect_to :controller => 'content'
  end

  def log_error(e, template = nil, force_log = false)
    if force_log || RAILS_ENV != 'production'
      if ErrorLog.count(:all) < 50
        ErrorLog.create :created_at => Time.now,
                        :message => "Error: #{e.class.name}\n Page: #{template}\n Message: #{e.clean_message[0, 500]}",
                        :location => (e.backtrace[0, 20].join("\n")[0, 2000] unless e.backtrace.blank?)
      end
    end
  end
end