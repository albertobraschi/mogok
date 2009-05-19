
module BgTasks

  class AbstractBgTask
    include BgTasks::Utils

    def exec(bg_task, logger = nil, force = false)
      begin_at = Time.now

      bg_task.schedule(logger) unless force

      if force || bg_task.exec_now?
        params = bg_task.params_hash
        begin

          do_exec(params)
          
          status = 'OK'
          logger.debug ":-) task #{bg_task.name} successfully executed" if logger
        rescue => e
          status = 'FAILED'
          log_task_error e, bg_task.name
          logger.error ":-( task #{bg_task.name} error: #{e.message}" if logger
          raise e if force
        end
        bg_task.log_exec(status, begin_at, Time.now) unless force
      end
    end
  end
end
