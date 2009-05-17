
class AnnounceLogsController < ApplicationController
  before_filter :logged_in_required
  before_filter :admin_required
  
  def index
    logger.debug ':-) announce_logs_controller.index'
    params[:order_by], params[:desc] = 'created_at', '1' if params[:order_by].blank?
    @announce_logs = AnnounceLog.search params, :per_page => APP_CONFIG[:page_size][:announce_logs]
    @announce_logs.desc_by_default = APP_CONFIG[:desc_by_default][:announce_logs] if @announce_logs
  end 

  def clear_all
    logger.debug ':-) announce_logs_controller.clear_all'
    if request.post?
      AnnounceLog.delete_all
    end
    redirect_to :action => 'index'
  end
end