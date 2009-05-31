
Topic.blueprint do
  title 'Topic Title'
  last_post_at Time.now
  topic_post { Post.make_unsaved(:topic_post, :user => user, :forum => forum) }
end
