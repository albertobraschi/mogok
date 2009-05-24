
# GIVEN

Then /^I have a new message to (.*) sent from (.*) in folder (.*) with subject (.*)$/ do |receiver, sender, folder, subject|
  m = Message.new
  m.owner = m.receiver = fetch_user(receiver)
  m.sender = fetch_user(sender)
  m.subject = subject
  m.unread = true
  m.folder = folder.downcase
  m.save
end


# WHEN

When /^I go to the new message page$/ do
  visit 'messages/new'
end

When /^I go to the messenger page for folder (.*)$/ do |folder|
  visit "messages/folder/#{folder.downcase}"
end

When /^application sends a system notification to (.*) with subject (.*) and body (.*)$/ do |receiver, subject, body|
  receiver = fetch_user receiver
  Message.deliver_system_notification(receiver, subject, body)
end


# THEN

Then /^a message should be sent to (.*) with subject (.*)$/ do |receiver, subject|
  receiver = fetch_user receiver
  Message.find_by_receiver_id_and_subject(receiver, subject).should_not == nil
end

Then /^a new message should be received by (.*) with subject (.*) and with body (.*)$/ do |receiver, subject, body|
  receiver = fetch_user receiver
  m = Message.find_by_receiver_id_and_subject_and_body(receiver, subject, body)
  m.should_not == nil
  m.unread.should == true
  m.folder == Message::INBOX
  receiver.has_new_message?.should == true
end

Then /^the message sent by (.*) with subject (.*) should be set as read$/ do |sender, subject|
  sender = fetch_user sender
  Message.find_by_sender_id_and_subject(sender, subject).unread?.should == false
end

Then /^the folder for message sent by (.*) with subject (.*) should be equal to (.*)$/ do |sender, subject, folder|
  sender = fetch_user sender
  Message.find_by_sender_id_and_subject(sender, subject).folder.should == folder.downcase
end




