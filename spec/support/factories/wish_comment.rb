
Factory.define :wish_comment do |c|
  c.body 'Whatever body.'
  c.comment_number { WishComment.count + 1 }
end