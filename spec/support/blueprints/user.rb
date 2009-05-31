
User.blueprint do
  password { username }
  password_confirmation { username }
  email {"#{username}@mail.com" }
end
