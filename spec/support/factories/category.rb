
Factory.define :category do |c|
  c.position { Category.count + 1 }
end
