
Factory.define :topic do |t|
  t.title 'Topic Title'
  t.last_post_at Time.now
  t.topic_post {|a| a.association(:post, :user => a.user, :forum => a.forum, :body => 'Topic post body.') }
end

