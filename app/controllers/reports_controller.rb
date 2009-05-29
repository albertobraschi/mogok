
class ReportsController < ApplicationController
  before_filter :logged_in_required
  before_filter :admin_mod_required

  def index
    logger.debug ':-) reports_controller.index'
    @reports = Report.all
  end

  def grab
    logger.debug ':-) reports_controller.grab'
    if request.post?
      Report.find(params[:id]).assign_to current_user
    end
    redirect_to :action => 'index'
  end

  def release
    logger.debug ':-) reports_controller.release'
    if request.post?
      Report.find(params[:id]).unassign
    end
    redirect_to :action => 'index'
  end

  def destroy
    logger.debug ':-) reports_controller.destroy'
    if request.post?
      Report.destroy params[:id]
    end
    redirect_to :action => 'index'
  end
end