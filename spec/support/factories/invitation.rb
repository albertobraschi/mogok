
Factory.define :invitation do |i|
  i.code { User.make_invite_code }
end

