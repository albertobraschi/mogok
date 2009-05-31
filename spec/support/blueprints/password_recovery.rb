
PasswordRecovery.blueprint do
  code { User.make_password_recovery_code }
end

