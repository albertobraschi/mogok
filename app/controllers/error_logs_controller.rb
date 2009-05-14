
class ErrorLogsController < ApplicationController
  before_filter :logged_in_required
  before_filter :admin_required
  
  def index
    logger.debug ':-) error_logs_controller.index'
    access_denied unless current_user.admin?
    @error_logs = ErrorLog.all :limit => 200
  end
   
  def clear_all
    logger.debug ':-) error_logs_controller.clear_all'
    if request.post?
      ErrorLog.delete_all
    end
    redirect_to :action => 'index'
  end
end