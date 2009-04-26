
class ErrorLogsController < ApplicationController
  before_filter :login_required
  before_filter :admin_required
  
  def index
    logger.debug ':-) error_logs_controller.index'
    access_denied unless logged_user.admin?
    @error_logs = ErrorLog.find :all, :order => 'created_at DESC', :limit => 200
  end
   
  def clear_all
    logger.debug ':-) error_logs_controller.clear_all'
    if request.post?
      ErrorLog.delete_all
    end
    redirect_to :action => 'index'
  end
end