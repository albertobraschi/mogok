
class BgTask

  # cleanup concern

  def self.cleanup(params)
    Log.delete_olds params[:log_max_age_days].days.ago
    AnnounceLog.delete_olds params[:announce_log_max_age_days].days.ago
    ErrorLog.delete_olds params[:error_log_max_age_days].days.ago
    BgTaskLog.delete_olds params[:task_log_max_age_days].days.ago

    Message.clear_trash
    Message.delete_olds params[:message_max_age_months].months.ago

    PeerConn.delete_peerless

    PasswordRecovery.delete_olds params[:password_recovery_max_age_days].days.ago
    Invitation.delete_olds params[:invitation_max_age_days].days.ago
    LoginAttempt.delete_expired
    SignupBlock.delete_expired
    
    User.destroy_or_inactivate_by_absense(params[:user_max_inactivity_days].days.ago)
  end
end
