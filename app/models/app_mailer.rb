
class AppMailer < ActionMailer::Base

  def password_recovery(user, code)
    recipients user.email
    from MAILER_CONFIG[:password_recovery_from]
    sent_on Time.now
    subject I18n.t('model.app_mailer.password_recovery.subject')
    body :recovery_link => change_password_url(:recovery_code => code)
  end

  def invitation(email, inviter, code)
    recipients email
    from MAILER_CONFIG[:invitation_from]
    sent_on Time.now
    subject I18n.t('model.app_mailer.invitation.subject')
    body :signup_link => signup_with_invite_url(:invite_code => code), :inviter => inviter
  end
end
