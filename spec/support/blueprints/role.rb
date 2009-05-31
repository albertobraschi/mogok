
Role.blueprint do
  css_class { "user_#{name}.css" }
  description { name.humanize.capitalize }
end
