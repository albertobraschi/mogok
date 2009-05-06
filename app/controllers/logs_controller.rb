
class LogsController < ApplicationController
  before_filter :login_required
  
  def index
    logger.debug ':-) logs_controller.index'        
    params[:keywords] = ApplicationHelper.process_search_keywords params[:keywords]
    @logs = Log.search params, logged_user, :per_page => APP_CONFIG[:logs_page_size]
  end
end
