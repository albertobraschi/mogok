
class AnnounceLogsController < ApplicationController
  before_filter :login_required
  before_filter :admin_required
  
  def index
    logger.debug ':-) announce_logs_controller.index'
    params[:order_by], params[:desc] = 'created_at', '1' if params[:order_by].blank?
    
    @announce_logs = AnnounceLog.paginate :conditions => index_conditions(params),
                                          :order => order_by,
                                          :per_page => APP_CONFIG[:announce_logs_page_size],
                                          :page => current_page
    if @announce_logs
      @announce_logs.desc_by_default = APP_CONFIG[:announce_logs_desc_by_default]
      @announce_logs.order_by = params[:order_by]
    end
  end 

  def clear_all
    logger.debug ':-) announce_logs_controller.clear_all'
    if request.post?
      AnnounceLog.delete_all
    end
    redirect_to :action => 'index'
  end
  
  private
  
  def index_conditions(params)
    s, h = '', {}
    unless params[:user_id].blank?
      s << 'user_id = :user_id '
      h[:user_id] = params[:user_id].to_i
      previous = true
    end
    unless params[:torrent_id].blank?
      s << 'AND ' if previous
      s << 'torrent_id = :torrent_id '
      h[:torrent_id] = params[:torrent_id].to_i
      previous = true
    end
    unless params[:ip].blank?
      s << 'AND ' if previous
      s << 'ip = :ip '
      h[:ip] = params[:ip]
      previous = true
    end
    unless params[:port].blank?
      s << 'AND ' if previous
      s << 'port = :port '
      h[:port] = params[:port].to_i
    end
    [s, h]
  end
end