
Factory.define :topic do |t|
  t.title 'Topic Title'
  t.last_post_at Time.now
  t.topic_post {|a| Factory(:topic_post, :user => a.user, :forum => a.forum) }
end
