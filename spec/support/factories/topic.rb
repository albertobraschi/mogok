
Factory.define :topic do |t|
  t.title 'Topic Title'
  t.last_post_at Time.now
  t.topic_post {|r| Post.new(:user => r.user, :forum => r.forum, :body => 'Topic post body.', :is_topic_post => true, :post_number => 1) }
end