 
module BgTasks

  class Cleanup
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
          Log.delete_all ['created_at < ?', config[:log_max_age_days].days.ago]
          Message.delete_all ['folder = ?', Message::TRASH]
          Message.delete_all ['created_at < ?', config[:message_max_age_months].months.ago]
          AnnounceLog.delete_all ['created_at < ?', config[:announce_log_max_age_days].days.ago]
          ErrorLog.delete_all ['created_at < ?', config[:error_log_max_age_days].days.ago]
          PeerConn.delete_peerless
          PasswordRecovery.delete_all ['created_at < ?', config[:password_recovery_max_age_days].days.ago]
          Invitation.delete_all ['created_at < ?', config[:invitation_max_age_days].days.ago]
          BgTaskLog.delete_all ['created_at < ?', config[:task_log_max_age_days].days.ago]
          LoginAttempt.delete_all ['blocked_until < ?', Time.now]
          SignupBlock.delete_all ['blocked_until < ?', Time.now]
          User.find_absents(config[:user_max_inactivity_days].days.ago).each do |u|
            next if u.has_ticket?(:staff)
            if u.torrents.count > 0
              u.toggle! :active # inactivate if user has at least one torrent
              log "User #{u.username} inactivated by system.", true
            else
              u.destroy
              log "User #{u.username} removed by system.", true
            end
          end
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
