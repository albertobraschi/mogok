
# GIVEN

Given /^I have a forum with name "(.*)"$/ do |name|
  make_forum name
end
        
Given /^I have a topic in forum "(.*)" with title "(.*)" and body "(.*)" and owned by user "(.*)"$/ do |forum_name, title, body, username|
  find_forum(forum_name).add_topic(title, body, find_user(username))
end


# THEN

Then /^a topic in forum "(.*)" with title "(.*)" and owned by user "(.*)" should be created$/ do |forum_name, title, username|
  f = find_forum(forum_name)
  Topic.find_by_forum_id_and_title_and_user_id(f, title, find_user(username)).should_not be_nil
end

Then /^the topic post for topic "(.*)" should have body equal to "(.*)"$/ do |topic_title, body|
  Topic.find_by_title(topic_title).topic_post.body.should == body
end


Then /^a post in topic "(.*)" with body "(.*)" and owned by user "(.*)" should be created$/ do |topic_title, body, username|
  t = Topic.find_by_title(topic_title)
  Post.find_by_topic_id_and_body_and_user_id(t, body, find_user(username)).should_not be_nil
end

Then /^a moderation report for topic "(.*)" with reason "(.*)" should be created$/ do |topic_title, reason|
  t = Topic.find_by_title(topic_title)
  label = Report.make_target_label(t)
  r = Report.find_by_target_label_and_reason(label, reason)
  r.should_not be_nil
  r.target_path.should == topics_path(:action => 'show', :forum_id => t.forum, :id => t)
end

