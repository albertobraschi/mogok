
# GIVEN

Then /^I have a new message to "(.*)" in folder "(.*)" sent by "(.*)" with subject "(.*)"$/ do |receiver, folder, sender, subject|
  m = Message.new
  m.owner = m.receiver = fetch_user(receiver)
  m.sender = fetch_user(sender)
  m.subject = subject
  m.unread = true
  m.folder = folder
  m.save
end


# WHEN

When /^application sends a system notification to "(.*)" with subject "(.*)" and body "(.*)"$/ do |receiver, subject, body|
  receiver = fetch_user receiver
  Message.deliver_system_notification(receiver, subject, body)
end


# THEN

Then /^a message with subject "(.*)" should be received by "(.*)"$/ do |subject, receiver|
  receiver = fetch_user receiver
  m = Message.find_by_receiver_id_and_subject(receiver, subject)
  m.should_not be_nil
  m.unread.should be_true
  m.folder.should == Message::INBOX
  receiver.has_new_message?.should be_true
end

Then /^a message with body containing "(.*)" and subject "(.*)" should be received by "(.*)"$/ do |body, subject, receiver|
  receiver = fetch_user receiver
  m = Message.find_by_receiver_id_and_subject(receiver, subject)
  m.should_not be_nil
  m.body.should include(body)  
  m.unread.should be_true
  m.folder.should == Message::INBOX
  receiver.has_new_message?.should be_true
end

Then /^a system message with subject "(.*)" should be received by "(.*)"$/ do |subject, receiver|
  receiver = fetch_user receiver
  m = Message.find_by_receiver_id_and_subject(receiver, subject)
  m.should_not be_nil
  m.sender.should == User.system_user
  m.unread.should be_true
  m.folder.should == Message::INBOX
  receiver.has_new_message?.should be_true
end

Then /^a system message with body containing "(.*)" and subject "(.*)" should be received by "(.*)"$/ do |body, subject, receiver|
  receiver = fetch_user receiver
  m = Message.find_by_receiver_id_and_subject(receiver, subject)
  m.should_not be_nil
  m.sender.should == User.system_user
  m.body.should include(body)
  m.unread.should be_true
  m.folder.should == Message::INBOX
  receiver.has_new_message?.should be_true
end

Then /^the message sent by "(.*)" with subject "(.*)" should be set as read$/ do |sender, subject|
  sender = fetch_user sender
  Message.find_by_sender_id_and_subject(sender, subject).unread?.should be_false
end

Then /^the folder for message sent by "(.*)" to "(.*)" with subject "(.*)" should be equal to "(.*)"$/ do |sender, receiver, subject, folder|
  sender = fetch_user sender
  receiver = fetch_user receiver
  Message.find_by_sender_id_and_receiver_id_and_subject(sender, receiver, subject).folder.should == folder
end









