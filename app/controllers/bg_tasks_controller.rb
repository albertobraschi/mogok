
class BgTasksController < ApplicationController
  include BgTasks::Utils
  before_filter :logged_in_required
  before_filter :admin_required
  
  def index
    logger.debug ':-) bg_tasks_controller.index'
    @bg_tasks = fetch_tasks
    @cron_jobs = list_cron_jobs
    @task_logs = BgTaskLog.all :limit => 10
  end

  def exec
    logger.debug ':-) bg_tasks_controller.exec'
    if request.post?
      begin
        t = BgTask.find params[:id]
        exec_task t, logger, true
        flash[:notice] = "Task #{t.name} successfully executed."
      rescue => e
        log_error e
        flash[:error] = "Task #{t.name} failed."
      end
    end
    redirect_to :action => 'index'
  end

  def edit
    logger.debug ':-) bg_tasks_controller.edit'
    @bg_task = BgTask.find params[:id]
    if request.post?      
      if @bg_task.update_attributes params[:bg_task]
        redirect_to :action => 'index'
      end
    end
  end

  def switch
    logger.debug ':-) bg_tasks_controller.switch'
    if request.post?
      t = BgTask.find params[:id]
      t.toggle! :active
    end
    redirect_to :action => 'index'
  end

  def reload
    logger.debug ':-) bg_tasks_controller.reload'
    if request.post?
      reload_tasks
    end
    redirect_to :action => 'index'
  end

  def logs
    logger.debug ':-) bg_tasks_controller.logs'
    @task_logs = BgTaskLog.all :limit => 400
  end

  def clear_logs
    logger.debug ':-) bg_tasks_controller.clear_logs'
    if request.post?
      BgTaskLog.delete_all
    end
    render :action => 'logs'
  end
  
  private

    def list_cron_jobs
      cron_jobs = %x{crontab -l}
      cron_jobs = nil if cron_jobs.blank? || cron_jobs.gsub("\n", '').strip.blank?
      cron_jobs
    end
end









