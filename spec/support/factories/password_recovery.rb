
Factory.define :password_recovery do |r|
  r.code { User.make_password_recovery_code }
end

