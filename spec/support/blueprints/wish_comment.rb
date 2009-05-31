
WishComment.blueprint do
  body 'Whatever body.'
  comment_number { WishComment.count + 1 }
end