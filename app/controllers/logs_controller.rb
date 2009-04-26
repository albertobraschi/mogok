
class LogsController < ApplicationController
  before_filter :login_required
  
  def index
    logger.debug ':-) logs_controller.index'
    params[:order_by], params[:desc] = 'created_at', '1' if params[:order_by].blank?
    params[:keywords] = ApplicationHelper.process_search_keywords params[:keywords]

    @logs = Log.paginate :conditions => index_conditions(params), 
                         :order => order_by,
                         :per_page => APP_CONFIG[:logs_page_size],
                         :page => current_page
    @logs.order_by = params[:order_by]
  end
  
  private
  
  def index_conditions(params)
    s, h = '', {}
    if logged_user.admin?
      if params[:admin] == '1'
        s << 'admin = TRUE '
        previous = true
      end
    else
      s << 'admin = FALSE '
      previous = true
    end
    unless params[:keywords].blank?
      s << 'AND ' if previous
      s << 'body LIKE :keywords'
      h[:keywords] = "%#{params[:keywords]}%"
    end
    [s, h]
  end
end
