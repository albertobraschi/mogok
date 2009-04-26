
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

  def add_log(text, reason = nil, admin = false)    
    text << " (#{reason})" unless reason.blank?
    text << '.'
    Log.create :created_at => Time.now, :body => text, :admin => admin
  end

  def current_page
    params[:page] = '1' if params[:page].blank?
    params[:page] == 'last' ? :last : params[:page].to_i
  end

  def order_by
    "#{params[:order_by]}#{' DESC' if params[:desc] == '1'}"
  end

  def cancelled?
    true unless params[:cancel].blank?
  end
end
