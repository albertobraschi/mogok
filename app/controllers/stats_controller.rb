
class StatsController < ApplicationController
  before_filter :logged_in_required
  before_filter :admin_required, :only => :history
  before_filter :owner_required, :only => :clear_all

  def index
    logger.debug ':-) stats_controller.index'
    @stat = Stat.newest
  end

  def history
    logger.debug ':-) stats_controller.history'
    @stats = Stat.paginate params, :per_page => APP_CONFIG[:page_size][:stats_history]
  end

  def clear_all
    logger.debug ':-) stats_controller.clear_all'
    if request.post?
      Stat.delete_all
    end
    redirect_to :action => 'history'
  end
end
