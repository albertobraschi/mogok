
Factory.define :post do |p|
  p.body 'Whatever body.'
  p.post_number { Post.count + 1 }
end

Factory.define :topic_post, :parent => :post, :default_strategy => :build do |p|
  p.is_topic_post true
  p.post_number 1
end
