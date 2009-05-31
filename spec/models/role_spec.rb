require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  before(:each) do
    @role_defective = fetch_role Role::DEFECTIVE
    @role_user      = fetch_role Role::USER
    @role_mod       = fetch_role Role::MODERATOR
    @role_admin     = fetch_role Role::ADMINISTRATOR
    @role_owner     = fetch_role Role::OWNER
    @role_system    = fetch_role Role::SYSTEM

    @admin     = fetch_user 'joe-the-admin', @role_admin
    @owner     = fetch_user 'joe-the-owner', @role_owner
    @system    = fetch_system_user
  end

  it 'should authorize by ticket' do
    @role_user.tickets = 'ticket_one ticket_two'
    @role_user.has_ticket?(:ticket_one).should be_true
    @role_user.has_ticket?(:ticket_three).should be_false
  end

  it 'should retrieve a list of roles to be used in search forms' do
    a = Role.all_for_search
    a.should_not include(@role_system)
  end

  it 'should retrieve a limited list of roles to be used in user edition forms' do
    a = Role.all_for_user_edition(@admin)
    a.should_not include(@role_admin)
    a.should_not include(@role_owner)
    a.should_not include(@role_system)

    a = Role.all_for_user_edition(@owner)
    a.should_not include(@role_system)

    a = Role.all_for_user_edition(@system)
    a.should_not include(@role_system)
  end
end