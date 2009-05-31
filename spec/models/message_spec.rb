require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
  include SupportVariables

  before(:each) do
    reload_support_variables
    
    @sender   = make_user('joe-the-sender', @role_user)
    @receiver = make_user('joe-the-receiver', @role_user)
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
    old_message = make_message(@sender, @sender, @receiver, 'old subject') # message to be replied

    m = Message.make_new({:subject => nil, :body => nil},
                         @sender,
                         {:to => @receiver.username, :reply => true, :message_id => old_message.id})
    m.subject.should == "#{I18n.t('model.message.prepare_to_reply.prefix')} #{old_message.subject}"
    m.body.should include("#{@receiver.username} #{I18n.t('model.message.prepare_to_reply.wrote')}")
  end

  it 'should build a new message instance prepared for forward given valid parameters' do
    old_message = make_message(@sender, @sender, @receiver, 'old subject') # message to be forwarded

    m = Message.make_new({:subject => nil, :body => nil},
                         @sender,
                         {:to => nil, :forward => true, :message_id => old_message.id})
    m.receiver.should == nil
    m.subject.should == "#{I18n.t('model.message.prepare_to_forward.prefix')} #{old_message.subject}"
    m.body.should include("#{@receiver.username} #{I18n.t('model.message.prepare_to_forward.wrote')}")
  end

  it 'should be set as read' do
    m = make_message(@receiver, @receiver, @sender)
    m.set_as_read
    m.reload

    m.should_not be_unread
  end

  it 'should be moved to another folder' do
    m = make_message(@receiver, @receiver, @sender)
    m.move_to_folder(Message::TRASH, @receiver)
    m.reload

    m.folder.should == Message::TRASH
  end

  # callbacks concern

    it 'should assign a default subject on delivery when subject empty' do
      m = make_message(@receiver, @receiver, @sender, false)
      m.deliver
      m.reload

      m.subject.should == I18n.t('model.message.before_create.default_subject')
    end

  # delivering concern

    it 'should be delivered' do
      m = make_message(@receiver, @receiver, @sender, false)
      m.deliver

      delivered = Message.find_by_receiver_id_and_subject(@receiver, m.subject)
      delivered.should_not be_nil
      delivered.folder.should == Message::INBOX
      delivered.should be_unread
    end

    it 'should delete replied message on delivery' do
      replied_message = make_message(@sender, @sender, @receiver)
      @sender.delete_on_reply = true
      @sender.save

      m = make_message(@receiver, @receiver, @sender, false)
      m.deliver(replied_message.id)

      Message.find_by_id(replied_message).folder.should == Message::TRASH
    end

    it 'should save sent message on delivery' do
      @sender.save_sent = true
      @sender.save

      m = make_message(@receiver, @receiver, @sender, false)
      m.deliver

      Message.find_by_owner_id_and_receiver_id_and_folder(@sender, @receiver, Message::SENT).should_not be_nil
    end

    it 'should set receiver new message flag on delivery' do
      @receiver.has_new_message = false
      @receiver.save

      m = make_message(@receiver, @receiver, @sender, false)
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
      m = make_message(@receiver, @receiver, @sender, false)
      m.deliver

      lambda {m.ensure_ownership(@user)}.should raise_error(Message::NotOwnerError)
      lambda {m.ensure_ownership(@receiver)}.should_not raise_error(Message::NotOwnerError)
    end
end
