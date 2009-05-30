require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @user      = fetch_user 'joe-the-user'
    @user_two  = fetch_user 'joe-the-user_two'
    @mod       = fetch_user 'joe-the-mod', fetch_role('mod')
    @mod_two   = fetch_user 'joe-the-mod_two', fetch_role('mod')
    @admin     = fetch_user 'joe-the-admin', fetch_role('admin')
    @admin_two = fetch_user 'joe-the-admin_two', fetch_role('admin')
    @owner     = fetch_user 'joe-the-owner', fetch_role('owner')
    @owner_two = fetch_user 'joe-the-owner_two', fetch_role('owner')
    @system    = fetch_system_user
  end

  # editable_by rules

    it 'should be editable by itself or an admin if a regular user' do
      @user.should be_editable_by(@user)
      @user.should_not be_editable_by(@user_two)
      @user.should_not be_editable_by(@mod)
      @user.should be_editable_by(@admin)
      @user.should be_editable_by(@owner)
      @user.should be_editable_by(@system)
    end

    it 'should be editable by itself or an admin if a moderator' do
      @mod.should be_editable_by(@mod)
      @mod.should_not be_editable_by(@user)
      @mod.should_not be_editable_by(@mod_two)
      @mod.should be_editable_by(@admin)
      @mod.should be_editable_by(@owner)
      @mod.should be_editable_by(@system)
    end

    it 'should be editable by itself, by an owner or by system if an admin' do
      @admin.should be_editable_by(@admin)
      @admin.should_not be_editable_by(@user)
      @admin.should_not be_editable_by(@mod)
      @admin.should_not be_editable_by(@admin_two)
      @admin.should be_editable_by(@owner)
      @admin.should be_editable_by(@system)
    end

    it 'should be editable by itself or system if an owner' do
      @owner.should be_editable_by(@owner)
      @owner.should_not be_editable_by(@user)
      @owner.should_not be_editable_by(@mod)
      @owner.should_not be_editable_by(@admin)
      @owner.should_not be_editable_by(@owner_two)
      @owner.should be_editable_by(@system)
    end

    it 'should be editable only by itself if system' do
      @system.should be_editable_by(@system)
      @system.should_not be_editable_by(@user)
      @system.should_not be_editable_by(@mod)
      @system.should_not be_editable_by(@admin)
      @system.should_not be_editable_by(@owner)
    end

  # rule assignment rules

    it 'should not allow an admin to assign role admin to another user' do
      @user.edit({:role_id => @admin.role.id}, @admin, nil)
      @user.errors[:role_id].should == 'forbidden assignment'
    end

    it 'should not allow an admin to assign role owner to another user or itself' do
      @admin.edit({:role_id => @owner.role.id}, @admin, nil)
      @admin.errors[:role_id].should == 'forbidden assignment'

      @user.edit({:role_id => @owner.role.id}, @admin, nil)
      @user.errors[:role_id].should == 'forbidden assignment'
    end

    it 'should not allow an admin to assign role system to another user or itself' do
      @admin.edit({:role_id => @system.role.id}, @admin, nil)
      @admin.errors[:role_id].should == 'forbidden assignment'

      @user.edit({:role_id => @system.role.id}, @admin, nil)
      @user.errors[:role_id].should == 'forbidden assignment'
    end

    it 'should not allow an owner to assign role system to another user or itself' do
      @owner.edit({:role_id => @system.role.id}, @owner, nil)
      @owner.errors[:role_id].should == 'forbidden assignment'

      @user.edit({:role_id => @system.role.id}, @owner, nil)
      @user.errors[:role_id].should == 'forbidden assignment'
    end

    it 'should not allow system to assign role system to another user' do
      @user.edit({:role_id => @system.role.id}, @system, nil)
      @user.errors[:role_id].should == 'forbidden assignment'
    end

  # edition checks

    it 'should require current password if user editing itself and user not admin' do
      @user.edit({}, @user, nil).should be_false
      @user.errors[:current_password].should == I18n.t('model.user.errors.current_password.required')

      @user_two.edit({}, @user_two, 'nonono').should be_false
      @user_two.errors[:current_password].should == I18n.t('model.user.errors.current_password.incorrect')
    end

    it 'should check if email available when editing' do
      @user.edit({:email => @user_two.email}, @user, nil).should be_false
      @user.errors[:email].should == I18n.t('model.user.errors.email.taken')
    end

    it 'should check if username available when admin edits an user' do
      @user.edit({:username => @user_two.username}, @admin, nil).should be_false
      @user.errors[:username].should == I18n.t('model.user.errors.username.taken')
    end

  # authentication and authorization

    it 'should authenticate' do
      User.authenticate(@user.username, @user.username).should == @user
      User.authenticate(@user.username, 'nononononono').should be_nil
    end

    it 'should authorize by tickets' do
      @user.tickets = 'ticket_one ticket_two'
      @user.has_ticket?(:ticket_one).should be_true
      @user.has_ticket?(:ticket_three).should be_false

      @user.role.tickets = 'ticket_three'
      @user.has_ticket?(:ticket_three).should be_true
    end

  # passkey resetting

    it 'should reset passkey with notification' do
      old_passkey = @user.passkey

      @user.reset_passkey_with_notification(@admin)
      @user.reload

      @user.passkey.should_not == old_passkey

      m = Message.find_by_receiver_id_and_subject @user, I18n.t('model.user.notify_passkey_resetting.subject')
      m.should_not be_nil
      m.body.should == I18n.t('model.user.notify_passkey_resetting.body')
    end

  # password recovery

    it 'should change the password given the valid parameters' do
      @user.change_password(nil, nil).should be_false
      @user.change_password('', '').should be_false
      @user.change_password('new_pass', 'nonono').should be_false

      @user.change_password('new_pass', 'new_pass').should be_true
      @user.reload
      User.authenticate(@user.username, 'new_pass').should == @user
    end

  # signup

    it 'should save new record with invitation code' do
      new_user = Factory.build(:user, :username => 'joe-the-new-user', :role => fetch_role, :style => fetch_style)
      invitation = Factory(:invitation, :user => @user, :email => 'joe-the-new-user@mail.com')

      new_user.save_new_with_invite(invitation.code, true)
      new_user.reload

      new_user.should_not be_new_record
      new_user.inviter.should == @user
      Invitation.find_by_code(invitation.code).should be_nil
    end

  # reporting

    it 'should be reportable' do
      @user.report @user_two, 'Whatever reason.', "users/show/#{@user.id}"
      Report.find_by_user_id_and_target_path(@user_two, "users/show/#{@user.id}").should_not be_nil
    end

  # ratio watch

    it 'should be put on ratio watch and notify itself' do
      fetch_role(Role::DEFECTIVE)
      @user.start_ratio_watch(30.days.from_now)
      @user.reload

      @user.should be_under_ratio_watch
      @user.role.should == fetch_role(Role::DEFECTIVE)
      @user.ratio_watch_until.should be_instance_of(Time)

      m = Message.find_by_receiver_id_and_subject @user, I18n.t('model.user.notify_ratio_watch.subject')
      m.should_not be_nil
      m.body.should == I18n.t('model.user.notify_ratio_watch.body', :watch_until => I18n.l(@user.ratio_watch_until, :format => :date))
    end

    it 'should be put out of ratio watch' do
      fetch_role(Role::DEFECTIVE)
      @user.start_ratio_watch(30.days.from_now)
      @user.reload

      @user.end_ratio_watch
      @user.reload

      @user.should_not be_under_ratio_watch
      @user.role.should == fetch_role(Role::USER)
      @user.ratio_watch_until.should be_nil
    end
end





