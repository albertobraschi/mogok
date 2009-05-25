
# GIVEN

Given /^I have a forum with name "(.*)"$/ do |forum_name|
  Forum.create(:name => forum_name, :position => 1)
end
        
Given /^I have a topic in forum "(.*)" with title "(.*)" and body "(.*)" and owned by user "(.*)"$/ do |forum_name, title, body, username|
  f = Forum.find_by_name(forum_name)
  u = fetch_user username
  f.add_topic(title, body, u)
end


# THEN

Then /^a topic in forum "(.*)" with title "(.*)" and owned by user "(.*)" should be created$/ do |forum_name, title, username|
  f = Forum.find_by_name(forum_name)
  u = fetch_user username
  Topic.find_by_forum_id_and_title_and_user_id(f, title, u).should_not be_nil
end

Then /^the topic post for topic "(.*)" should have body equal to "(.*)"$/ do |topic_title, body|
  t = Topic.find_by_title(topic_title)
  t.topic_post.body.should == body
end


Then /^a post in topic "(.*)" with body "(.*)" and owned by user "(.*)" should be created$/ do |topic_title, body, username|
  t = Topic.find_by_title(topic_title)
  u = fetch_user username
  Post.find_by_topic_id_and_body_and_user_id(t, body, u).should_not be_nil
end

Then /^a moderation report for topic "(.*)" with reason "(.*)" should be created$/ do |topic_title, reason|
  t = Topic.find_by_title(topic_title)
  label = Report.make_target_label(t)
  Report.find_by_target_label_and_reason(label, reason).should_not be_nil
end

