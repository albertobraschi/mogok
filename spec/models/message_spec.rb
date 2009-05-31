require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
  before(:each) do
    @system   = fetch_system_user
    @sender   = fetch_user 'joe-the-sender'
    @receiver = fetch_user 'joe-the-receiver'
    @user     = fetch_user 'joe-the-user'
  end

  it 'should build a new message instance given valid parameters' do
    m = Message.make_new({:subject => 'message subject', :body => 'Message body.'},
                         @sender,
                         {:to => @receiver.username})
    m.owner.should == @receiver
    m.receiver.should == @receiver
    m.sender.should == @sender
    m.subject.should == 'message subject'
    m.body.should == 'Message body.'
  end

  it 'should build a new message instance prepared for reply given valid parameters' do
    old_message = Factory(:message, :owner => @sender, :receiver => @sender, :sender => @receiver)

    m = Message.make_new({:subject => nil, :body => nil},
                         @sender,
                         {:to => @receiver.username, :reply => true, :message_id => old_message.id})
    m.subject.should == "#{I18n.t('model.message.prepare_to_reply.prefix')} #{old_message.subject}"
    m.body.should include("#{@receiver.username} #{I18n.t('model.message.prepare_to_reply.wrote')}")
  end

  it 'should build a new message instance prepared for forward given valid parameters' do
    old_message = Factory(:message, :owner => @sender, :receiver => @sender, :sender => @receiver)

    m = Message.make_new({:subject => nil, :body => nil},
                         @sender,
                         {:to => nil, :forward => true, :message_id => old_message.id})
    m.receiver.should == nil
    m.subject.should == "#{I18n.t('model.message.prepare_to_forward.prefix')} #{old_message.subject}"
    m.body.should include("#{@receiver.username} #{I18n.t('model.message.prepare_to_forward.wrote')}")
  end

  it 'should be set as read' do
    m = Factory(:message, :owner => @receiver, :receiver => @receiver, :sender => @sender)
    m.set_as_read
    m.reload

    m.should_not be_unread
  end

  it 'should be moved to another folder' do
    m = Factory(:message, :owner => @receiver, :receiver => @receiver, :sender => @sender)
    m.move_to_folder(Message::TRASH, @receiver)
    m.reload

    m.folder.should == Message::TRASH
  end

  # delivering concern

    it 'should be delivered' do
      m = Factory.build(:message, :owner => @receiver, :receiver => @receiver, :sender => @sender)
      m.deliver

      delivered = Message.find_by_receiver_id_and_subject(@receiver, m.subject)
      delivered.should_not be_nil
      delivered.folder.should == Message::INBOX
      delivered.should be_unread
    end

    it 'should delete replied message on delivery' do
      replied_message = Factory(:message, :owner => @sender, :receiver => @sender, :sender => @receiver)
      @sender.delete_on_reply = true
      @sender.save

      m = Factory.build(:message, :owner => @receiver, :receiver => @receiver, :sender => @sender)
      m.deliver(replied_message.id)

      Message.find_by_id(replied_message).folder.should == Message::TRASH
    end

    it 'should save sent message on delivery' do
      @sender.save_sent = true
      @sender.save

      m = Factory.build(:message, :owner => @receiver, :receiver => @receiver, :sender => @sender)
      m.deliver

      Message.find_by_owner_id_and_receiver_id_and_folder(@sender, @receiver, Message::SENT).should_not be_nil
    end

    it 'should set receiver new message flag on delivery' do
      @receiver.has_new_message = false
      @receiver.save

      m = Factory.build(:message, :owner => @receiver, :receiver => @receiver, :sender => @sender)
      m.deliver
      @receiver.reload

      @receiver.has_new_message.should be_true
    end

    it 'should deliver a system notification' do
      Message.deliver_system_notification(@receiver, 'system notifying', 'Notification body.')

      m = Message.find_by_receiver_id_and_sender_id(@receiver, @system)
      m.should_not be_nil
      m.subject.should == 'system notifying'
      m.body.should == 'Notification body.'
      m.folder.should == Message::INBOX
      m.should be_unread
    end

  # ownership concern
  
    it 'should ensure ownership' do
      m = Factory.build(:message, :owner => @receiver, :receiver => @receiver, :sender => @sender)
      m.deliver

      lambda {m.ensure_ownership(@user)}.should raise_error(Message::NotOwnerError)
      lambda {m.ensure_ownership(@receiver)}.should_not raise_error(Message::NotOwnerError)
    end
end
