
Factory.define :role do |r|
  r.name {|a| a.name }
  r.css_class {|a| "user_#{a.name}.css" }
  r.description {|a| a.name.humanize.capitalize }
end