
# GIVEN

Then /^I have a new message to "(.*)" in folder "(.*)" sent by "(.*)" with subject "(.*)"$/ do |receiver, folder, sender, subject|
  Factory(:message, :owner => fetch_user(receiver),
                    :receiver => fetch_user(receiver),
                    :sender => fetch_user(sender),
                    :subject => subject,
                    :folder => folder)
end


# WHEN

When /^application sends a system notification to "(.*)" with subject "(.*)" and body "(.*)"$/ do |receiver, subject, body|
  Message.deliver_system_notification(fetch_user(receiver), subject, body)
end


# THEN

Then /^a message with subject "(.*)" should be received by "(.*)"$/ do |subject, receiver|
  m = Message.find_by_receiver_id_and_subject fetch_user(receiver), subject
  m.should_not be_nil
  m.unread.should be_true
  m.folder.should == Message::INBOX
  fetch_user(receiver).has_new_message?.should be_true
end

Then /^a message with body containing "(.*)" and subject "(.*)" should be received by "(.*)"$/ do |body, subject, receiver|
  m = Message.find_by_receiver_id_and_subject fetch_user(receiver), subject
  m.should_not be_nil
  m.body.should include(body)  
  m.unread.should be_true
  m.folder.should == Message::INBOX
  fetch_user(receiver).has_new_message?.should be_true
end

Then /^a system message with subject "(.*)" should be received by "(.*)"$/ do |subject, receiver|
  m = Message.find_by_receiver_id_and_subject fetch_user(receiver), subject
  m.should_not be_nil
  m.sender.should == User.system_user
  m.unread.should be_true
  m.folder.should == Message::INBOX
  fetch_user(receiver).has_new_message?.should be_true
end

Then /^a system message with body containing "(.*)" and subject "(.*)" should be received by "(.*)"$/ do |body, subject, receiver|
  m = Message.find_by_receiver_id_and_subject fetch_user(receiver), subject
  m.should_not be_nil
  m.sender.should == User.system_user
  m.body.should include(body)
  m.unread.should be_true
  m.folder.should == Message::INBOX
  fetch_user(receiver).has_new_message?.should be_true
end

Then /^the message sent by "(.*)" with subject "(.*)" should be set as read$/ do |sender, subject|
  Message.find_by_sender_id_and_subject(fetch_user(sender), subject).unread?.should be_false
end

Then /^the folder for message sent by "(.*)" to "(.*)" with subject "(.*)" should be equal to "(.*)"$/ do |sender, receiver, subject, folder|
  m = Message.find_by_sender_id_and_receiver_id_and_subject(fetch_user(sender), fetch_user(receiver), subject)
  m.folder.should == folder
end









