
class ApplicationController < ActionController::Base
  include AppAuthentication, AppAuthorization, AppErrorHandling
  protect_from_forgery
  helper :all    

  protected

    def after_login_required # callback from access_control
      set_user_warnings
    end

    def set_user_warnings
      if current_user.admin?
        @error_log_alert = ErrorLog.has? # check if there are error logs
      elsif current_user.mod?
        @report_alert = Report.has_open? # check if there are open reports
      end
    end

    def t(key, args = {})
      super "controller.#{params[:controller]}.#{params[:action]}.#{key}", args # I18n shortcut, check 'en.yml'
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
