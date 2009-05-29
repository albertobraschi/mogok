
Factory.define :forum do |c|
  c.position { Forum.count + 1 }
end
