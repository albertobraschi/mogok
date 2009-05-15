 
module BgTasks

  class Cleanup
    include BgTasks::Utils

    def exec(bg_task, config, logger = nil, force = false)
      begin_at = Time.now

      bg_task.schedule(logger) unless force

      if force || bg_task.exec_now?
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
              app_log "User #{u.username} inactivated by system.", true
            else
              u.destroy
              app_log "User #{u.username} removed by system.", true
            end
          end
          logger.debug ":-) task #{bg_task.name} successfully executed" if logger
          status = 'OK'
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
