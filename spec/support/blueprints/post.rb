
Post.blueprint do
  body 'Whatever body.'
  post_number { Post.count + 1 }
end

Post.blueprint(:topic_post) do
  is_topic_post true
  post_number 1
end

# User.make(:admin)
