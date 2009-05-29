
Factory.define :style do |s|
  s.stylesheet {|a| "#{a.name}.css" }
end