
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

Then /^a new message should be received by "(.*)" with subject "(.*)" and body containing "(.*)"$/ do |receiver, subject, body|
  receiver = fetch_user receiver
  m = Message.find_by_receiver_id_and_subject(receiver, subject)
  m.should_not be_nil
  m.body.should include(body)  
  m.unread.should be_true
  m.folder.should == Message::INBOX
  receiver.has_new_message?.should be_true
end

Then /^a new system message should be received by "(.*)" with subject "(.*)" and body "(.*)"$/ do |receiver, subject, body|
  receiver = fetch_user receiver
  m = Message.find_by_receiver_id_and_subject_and_body(receiver, subject, body)
  m.should_not be_nil
  m.sender.should == User.system_user
  m.unread.should be_true
  m.folder.should == Message::INBOX
  receiver.has_new_message?.should be_true
end

Then /^the message sent by "(.*)" with subject "(.*)" should be set as read$/ do |sender, subject|
  sender = fetch_user sender
  Message.find_by_sender_id_and_subject(sender, subject).unread?.should be_false
end

Then /^the folder for message sent by "(.*)" with subject "(.*)" should be equal to "(.*)"$/ do |sender, subject, folder|
  sender = fetch_user sender
  Message.find_by_sender_id_and_subject(sender, subject).folder.should == folder
end

Then /^a message should be sent to "(.*)" with subject "(.*)"$/ do |receiver, subject|
  receiver = fetch_user receiver
  Message.find_by_receiver_id_and_subject(receiver, subject).should_not be_nil
end








