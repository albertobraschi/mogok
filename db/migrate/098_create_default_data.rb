
class CreateDefaultData < ActiveRecord::Migration

  def self.up
    # application database params (value will be evaluated to code by Kernel method eval)
    AppParam.create :name => 'signup_open', :value => 'true'
    AppParam.create :name => 'signup_by_invitation_only', :value => 'true'

    # user roles required by the application
    self.create_role 1, Role::SYSTEM, 'System','user_system', 'staff'
    self.create_role 2, Role::OWNER, 'Owner','user_owner', 'staff inviter'
    self.create_role 3, Role::ADMINISTRATOR, 'Administrator','user_admin', 'staff inviter'
    self.create_role 4, Role::MODERATOR, 'Moderator','user_mod', 'staff inviter'
    self.create_role 5, Role::USER, 'User','user_user'

    # style and country
    s = Style.create :id => 1, :name => 'default', :stylesheet => 'default.css'
    c = Country.create(:name => 'Earth', :image => 'earth.gif')

    # users
    role_system = Role.find_by_name Role::SYSTEM
    self.create_user 1, 'system', role_system, s # system user must have the id 1
    
    role_owner = Role.find_by_name Role::OWNER
    self.create_user 2, 'owner', role_owner, s, c
  end

  def self.down
    Country.delete_all
    Style.delete_all
    Role.delete_all
    User.delete_all
    AppParam.delete_all
  end

  private

  def self.create_role(id, name, description, css_class, tickets = nil)
    r = Role.new :id => id, :description => description, :css_class => css_class, :tickets => tickets
    r.name = name # attribute name must be assigned separately
    r.save
  end

  def self.create_user(id, username, role, style, country = nil)
    style = Style.find_by_name 'default'
    u = User.new(:id => id,
                 :username => username,
                 :password => username,
                 :created_at => Time.now,
                 :last_login_at => Time.now,
                 :last_seen_at => Time.now,
                 :style_id => style.id,
                 :country_id => (country.id if country),
                 :email => "#{username}@mail.com",
                 :display_downloads => false,
                 :display_last_seen_at => false,
                 :uploaded => 0,
                 :downloaded => 0)
    u.role = role # attribute role_id must be assigned separately
    u.reset_passkey
    u.save(false)
  end
end
