require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  include SupportVariables

  before(:each) do
    reload_support_variables

    @user_two       = make_user('joe-the-user_two', @role_user)
    @user_three     = make_user('joe-the-user_three', @role_user)
    @power_user_two = make_user('joe-the-power_user_2', @role_power_user)
    @mod_two        = make_user('joe-the-mod_two', @role_mod)
    @admin_two      = make_user('joe-the-admin_two', @role_admin)
    @owner_two      = make_user('joe-the-owner_two', @role_owner)
  end

  # main class

    # editable_by rules

      it 'should be editable by itself or an admin if a regular user' do
        @user.should be_editable_by(@user)
        @user.should_not be_editable_by(@user_two) # 'user' role behaves like any other custom role
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

      it 'should be editable by itself or by an owner if an admin' do
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

    # role assignment rules

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

    # editing checks

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

    # reporting

      it 'should be reportable' do
        @user.report @user_two, 'Whatever reason.', "users/show/#{@user.id}"
        Report.find_by_user_id_and_target_path(@user_two, "users/show/#{@user.id}").should_not be_nil
      end

  # authentication concern

    it 'should authenticate' do
      User.authenticate(@user.username, @user.username).should == @user
      User.authenticate(@user.username, 'nononononono').should be_nil
    end

  # authorization concern

    it 'should authorize by ticket' do
      @user.tickets = 'ticket_one ticket_two'
      @user.has_ticket?(:ticket_one).should be_true
      @user.has_ticket?(:ticket_three).should be_false

      @user.role.tickets = 'ticket_three'
      @user.has_ticket?(:ticket_three).should be_true
    end

    it 'should add a ticket' do
      @user.add_ticket!(:ticket_one)
      @user.reload

      @user.has_ticket?(:ticket_one).should be_true
    end

    it 'should remove a ticket' do
      @user.add_ticket!(:ticket_one)
      @user.add_ticket!(:ticket_two)
      @user.reload

      @user.remove_ticket!(:ticket_one)
      @user.reload

      @user.has_ticket?(:ticket_one).should be_false
      @user.has_ticket?(:ticket_two).should be_true
    end

  # password recovering concern

    it 'should change the password given the valid parameters' do
      @user.change_password(nil, nil).should be_false
      @user.change_password('', '').should be_false
      @user.change_password('new_pass', 'nonono').should be_false

      @user.change_password('new_pass', 'new_pass').should be_true
      @user.reload
      User.authenticate(@user.username, 'new_pass').should == @user
    end

  # ratio policy concern

    it 'should indicate if it is under ratio watch' do
      @user.role = @role_defective
      @user.ratio_watch_until = 30.days.from_now
      @user.save
      @user.reload

      @user.should be_under_ratio_watch
    end

    it 'should be put on ratio watch and notify itself' do
      @user.start_ratio_watch(30.days.from_now)
      @user.reload

      @user.should be_under_ratio_watch
      @user.role.should == @role_defective
      @user.ratio_watch_until.should be_instance_of(Time)

      m = Message.find_by_receiver_id_and_subject @user, I18n.t('model.user.notify_ratio_watch.subject')
      m.should_not be_nil
      m.body.should == I18n.t('model.user.notify_ratio_watch.body', :watch_until => I18n.l(@user.ratio_watch_until, :format => :date))
    end

    it 'should be put out of ratio watch' do
      @user.start_ratio_watch(30.days.from_now)
      @user.reload

      @user.end_ratio_watch
      @user.reload

      @user.should_not be_under_ratio_watch
      @user.role.should == @role_user
      @user.ratio_watch_until.should be_nil
    end
  
    it 'should put users under ratio watch based in their downloaded counters and ratios' do
      min_downloaded = 100
      max_downloaded = 500
      min_ratio = 0.5

      @user.increment_counters(100, 400) # ratio 0.25
      @user_two.increment_counters(400, 400) # ratio 1
      @power_user.increment_counters(100, 400) # ratio 0.25

      User.start_ratio_watch(min_downloaded, max_downloaded, min_ratio, 30.days.from_now)
      @user.reload
      @user_two.reload
      @power_user.reload

      @user.role.should == @role_defective
      @user_two.role.should == @role_user
      @power_user.role.should == @role_defective
    end

    it 'should end users ratio watch' do
      min_downloaded = 100
      max_downloaded = 500
      min_ratio = 0.5

      @user.increment_counters(400, 400) # ratio 1
      @user.role = @role_defective
      @user.ratio_watch_until = 1.day.ago
      @user.save

      @user_two.increment_counters(100, 400) # ratio 0.25
      @user_two.role = @role_defective
      @user_two.ratio_watch_until = 1.day.ago
      make_torrent(@user_two) # so it won't be removed, only inactivated
      @user_two.save

      @user_three.increment_counters(100, 400) # ratio 0.25
      @user_three.role = @role_defective
      @user_three.ratio_watch_until = 1.day.ago
      @user_three.save

      User.finish_ratio_watch(min_downloaded, max_downloaded, min_ratio)
      @user.reload
      @user_two.reload

      @user.role.should == @role_user
      @user_two.role.should == @role_defective
      @user_two.should_not be_active
      User.find_by_id(@user_three.id).should be_nil
    end

    it 'should promote or demote users based in their data transfer counters' do
      min_uploaded = 100
      min_ratio = 0.5

      @user.increment_counters(200, 200) # ratio 1
      @user_two.increment_counters(200, 800) # ratio 0.25
      @power_user.increment_counters(200, 200) # ratio 1
      @power_user_two.increment_counters(200, 800) # ratio 0.25

      User.promote_demote_by_data_transfer(@role_user.name, @role_power_user.name, min_uploaded, min_ratio)
      @user.reload
      @user_two.reload
      @power_user.reload
      @power_user_two.reload

      @user.role.should == @role_power_user
      @user_two.role.should == @role_user
      @power_user.role.should == @role_power_user
      @power_user_two.role.should == @role_user
    end

  # signup concern

    it 'should save new record with invitation code' do
      new_user = make_user('joe-the-new-user', @role_user, false)
      invitation = make_invitation(@user, 'joe-the-new-user@mail.com')

      new_user.save_new_with_invite(invitation.code, true)
      new_user.reload

      new_user.should_not be_new_record
      new_user.inviter.should == @user
      Invitation.find_by_code(invitation.code).should be_nil
    end

  # tracker concern

    it 'should increment downloaded and uploaded counters and set ratio' do
      @user.increment_counters(100, 100)
      @user.reload

      @user_two.increment_counters(100, 45)
      @user_two.reload

      @user.uploaded.should == 100
      @user.downloaded.should == 100
      @user.ratio.should == 1
      @user_two.ratio.to_f.should == 2.222
    end

    it 'should reset passkey with notification' do
      old_passkey = @user.passkey

      @user.reset_passkey_with_notification(@admin)
      @user.reload

      @user.passkey.should_not == old_passkey

      m = Message.find_by_receiver_id_and_subject @user, I18n.t('model.user.notify_passkey_resetting.subject')
      m.should_not be_nil
      m.body.should == I18n.t('model.user.notify_passkey_resetting.body')
    end
end





