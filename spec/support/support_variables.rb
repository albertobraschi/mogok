
module SupportVariables

  def reload_support_variables
    @role_system     = fetch_role Role::SYSTEM
    @role_owner      = fetch_role Role::OWNER
    @role_admin      = fetch_role Role::ADMINISTRATOR
    @role_mod        = fetch_role Role::MODERATOR
    @role_user       = fetch_role Role::USER
    @role_defective  = fetch_role Role::DEFECTIVE
    @role_power_user = fetch_role 'power_user'

    @system     = make_system_user # needed for system notification messages
    
    @owner      = make_user 'joe-the-owner', @role_owner
    @admin      = make_user 'joe-the-admin', @role_admin
    @mod        = make_user 'joe-the-mod', @role_mod
    @user       = make_user 'joe-the-user', @role_user
    @power_user = make_user 'joe-the-power_user', @role_power_user
  end
end