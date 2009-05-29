
Factory.define :user do |u|
  u.password {|r| r.username }
  u.password_confirmation {|r| r.username }
  u.email {|r| r.email.blank? ? "#{r.username}@mail.com" : r.email }
end