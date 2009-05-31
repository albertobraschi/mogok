
Comment.blueprint do
  body 'Whatever body.'
  comment_number { Comment.count + 1 }
end