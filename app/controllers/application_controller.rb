
class ApplicationController < ActionController::Base
  include AccessControl, ErrorHandling
  helper :all
  helper_method :logged_user
  protect_from_forgery
  filter_parameter_logging :password
  rescue_from Exception, :with => :handle_error

  protected

  def after_login_required # callback from access_control
    set_user_warnings
  end

  def set_user_warnings
    if logged_user.admin?
      @error_log_alert = true if ErrorLog.find(:first) # check if there are error logs
    elsif logged_user.mod?
      @report_alert = true if Report.find(:first, :conditions => {:handler_id => nil}) # check if there are reports
    end
  end

  def t(key, args = {})
    super "controller.#{params[:controller]}.#{params[:action]}.#{key}", args # I18n shortcut, check 'en.yml'
  end

  def add_log(text, reason = nil, admin = false)    
    text << " (#{reason})" unless reason.blank?
    text << '.'
    Log.create :created_at => Time.now, :body => text, :admin => admin
  end

  def cancelled?
    true unless params[:cancel].blank?
  end
end
