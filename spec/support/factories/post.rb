
Factory.define :post do |p|
  p.body 'Whatever body.'
  p.post_number { Post.count + 1 }
  p.topic_id 0 # or factory girl will complain when topic factory create the topic_post
end