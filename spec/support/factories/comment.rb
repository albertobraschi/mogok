
Factory.define :comment do |c|
  c.body 'Whatever body.'
  c.comment_number { Comment.count + 1 }
end