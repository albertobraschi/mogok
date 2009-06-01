
# given

  Then /^I have a new message to "(.*)" in folder "(.*)" sent by "(.*)" with subject "(.*)"$/ do |receiver, folder, sender, subject|
    make_message(find_user(receiver), find_user(receiver), find_user(sender), subject, folder)
  end

# when

  When /^application sends a system notification to "(.*)" with subject "(.*)" and body "(.*)"$/ do |receiver, subject, body|
    Message.deliver_system_notification(find_user(receiver), subject, body)
  end

# then

  Then /^a message with subject "(.*)" should be received by "(.*)"$/ do |subject, receiver|
    m = Message.find_by_receiver_id_and_subject find_user(receiver), subject
    m.should_not be_nil
    m.unread.should be_true
    m.folder.should == Message::INBOX
    find_user(receiver).has_new_message?.should be_true
  end

  Then /^a message with body containing "(.*)" and subject "(.*)" should be received by "(.*)"$/ do |body, subject, receiver|
    m = Message.find_by_receiver_id_and_subject find_user(receiver), subject
    m.should_not be_nil
    m.body.should include(body)
    m.unread.should be_true
    m.folder.should == Message::INBOX
    find_user(receiver).has_new_message?.should be_true
  end

  Then /^a system message with subject "(.*)" should be received by "(.*)"$/ do |subject, receiver|
    m = Message.find_by_receiver_id_and_subject find_user(receiver), subject
    m.should_not be_nil
    m.sender.should == User.system_user
    m.unread.should be_true
    m.folder.should == Message::INBOX
    find_user(receiver).has_new_message?.should be_true
  end

  Then /^a system message with body containing "(.*)" and subject "(.*)" should be received by "(.*)"$/ do |body, subject, receiver|
    m = Message.find_by_receiver_id_and_subject find_user(receiver), subject
    m.should_not be_nil
    m.sender.should == User.system_user
    m.body.should include(body)
    m.unread.should be_true
    m.folder.should == Message::INBOX
    find_user(receiver).has_new_message?.should be_true
  end

  Then /^the message sent by "(.*)" with subject "(.*)" should be set as read$/ do |sender, subject|
    Message.find_by_sender_id_and_subject(find_user(sender), subject).unread?.should be_false
  end

  Then /^the folder for message sent by "(.*)" to "(.*)" with subject "(.*)" should be equal to "(.*)"$/ do |sender, receiver, subject, folder|
    m = Message.find_by_sender_id_and_receiver_id_and_subject(find_user(sender), find_user(receiver), subject)
    m.folder.should == folder
  end









