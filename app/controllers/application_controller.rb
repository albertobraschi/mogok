
class ApplicationController < ActionController::Base
  include AuthenticatedSystem, AuthorizedSystem, ErrorHandling
  protect_from_forgery
  helper :all

  filter_parameter_logging :password

  protected

    def after_logged_in_required # callback from app_authorization
      current_user.register_access
      set_user_alerts
    end

    def set_user_alerts
      if current_user.admin?
        def current_user.error_log?
          ErrorLog.has?
        end
      elsif current_user.mod?
        def current_user.open_report?
          Report.has_open?
        end
      end
    end

    def t(key, args = {})
      super "controller.#{params[:controller]}.#{params[:action]}.#{key}", args # I18n convenience
    end

    def add_log(text, reason = nil, admin = false)
      text << " (#{reason})" unless reason.blank?
      text << '.'
      Log.create text, admin
    end

    def cancelled?
      true unless params[:cancel].blank?
    end
end
