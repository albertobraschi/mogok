 
module BgTasks

  class Cleanup < AbstractBgTask

    protected

      def do_exec(params)
        Log.delete_all ['created_at < ?', params[:log_max_age_days].days.ago]
        Message.delete_all ['folder = ?', Message::TRASH]
        Message.delete_all ['created_at < ?', params[:message_max_age_months].months.ago]
        AnnounceLog.delete_all ['created_at < ?', params[:announce_log_max_age_days].days.ago]
        ErrorLog.delete_all ['created_at < ?', params[:error_log_max_age_days].days.ago]
        PeerConn.delete_peerless
        PasswordRecovery.delete_all ['created_at < ?', params[:password_recovery_max_age_days].days.ago]
        Invitation.delete_all ['created_at < ?', params[:invitation_max_age_days].days.ago]
        BgTaskLog.delete_all ['created_at < ?', params[:task_log_max_age_days].days.ago]
        LoginAttempt.delete_all ['blocked_until < ?', Time.now]
        SignupBlock.delete_all ['blocked_until < ?', Time.now]
        User.find_absents(params[:user_max_inactivity_days].days.ago).each do |u|
          next if u.has_ticket?(:staff) || u.has_ticket?(:inactivity_exempt)
          if u.torrents.count > 0
            u.inactivate # inactivate if user has at least one torrent
            app_log "User #{u.username} inactivated by system (unused account)."
          else
            u.destroy
            app_log "User #{u.username} removed by system (unused account)."
          end
        end
      end
  end
end
