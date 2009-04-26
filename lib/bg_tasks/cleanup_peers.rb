 
module BgTasks

  class CleanupPeers
    include BgTasks::Utils
    
    def exec(bg_task, config, logger = nil, force = false)
      exec_begin_at = Time.now

      unless force
        exec_now = bg_task.next_exec_at && bg_task.next_exec_at < Time.now
        if exec_now || bg_task.next_exec_at.blank?
          bg_task.next_exec_at = Time.now + bg_task.interval_minutes.minutes
          bg_task.save
          logger.debug ":-) TASK #{bg_task.name} scheduled to #{bg_task.next_exec_at.to_s :db}" if logger
        end
      end

      if force || exec_now
        begin
          Peer.destroy_all ['last_action_at < ?', config[:peer_max_inactivity_minutes].minutes.ago]
          logger.debug ":-) TASK #{bg_task.name} successfully executed" if logger
          status = 'OK'
        rescue => e
          status = 'FAILED'
          log_error e, bg_task.name
          logger.error ":-( TASK #{bg_task.name} ERROR: #{e.message}" if logger
          raise e if force
        end
      end
      if status && !force
        log_task_exec bg_task.name, status, exec_begin_at, Time.now, bg_task.next_exec_at
      end
    end
  end
end
