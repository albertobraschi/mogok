 
module BgTasks

  class CleanupPeers
    include BgTasks::Utils
    
    def exec(bg_task, config, logger = nil, force = false)
      begin_at = Time.now

      bg_task.schedule(logger) unless force

      if force || bg_task.exec_now?
        begin
          Peer.delete_inactives config[:peer_max_inactivity_minutes].minutes.ago
          logger.debug ":-) task #{bg_task.name} successfully executed" if logger
          status = 'ok'
        rescue => e
          status = 'failed'
          log_error e, bg_task.name
          logger.error ":-( task #{bg_task.name} error: #{e.message}" if logger
          raise e if force
        end
        bg_task.log_exec(status, begin_at, Time.now) unless force
      end      
    end
  end
end
