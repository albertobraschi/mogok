
class CreateDefaultData < ActiveRecord::Migration

  def self.up
    # application database params (values can be anything loadable by YAML)
    AppParam.create :name => 'signup_open'              , :value => 'true'
    AppParam.create :name => 'signup_by_invitation_only', :value => 'true'

    # default roles
    self.create_role 1, Role::SYSTEM       , 'System'       ,'user_system'   , 'staff'
    self.create_role 2, Role::OWNER        , 'Owner'        ,'user_owner'    , 'staff inviter wisher'
    self.create_role 3, Role::ADMINISTRATOR, 'Administrator','user_admin'    , 'staff inviter wisher'
    self.create_role 4, Role::MODERATOR    , 'Moderator'    ,'user_mod'      , 'staff inviter wisher'
    self.create_role 5, Role::USER         , 'User'         ,'user_user'     , 'wisher'
    self.create_role 5, Role::DEFECTIVE    , 'Defective'    ,'user_defective'

    # default style
    s = Style.create :id => 1, :name => 'default', :stylesheet => 'default.css'

    # default country
    c = Country.create(:name => 'Earth', :image => 'earth.gif')

    # default users
    self.create_user 1, 'system', Role.find_by_name(Role::SYSTEM), s # system user must have the id 1
    self.create_user 2, 'owner', Role.find_by_name(Role::OWNER), s, c
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
      r.name = name # attribute name is protected and must be assigned separately
      r.save
    end

    def self.create_user(id, username, role, style, country = nil)
      style = Style.find_by_name 'default'
      u = User.new(:id => id,
                   :username => username,
                   :password => username,
                   :style => style,
                   :country => (country if country),
                   :email => "#{username}@mail.com",
                   :save_sent => false,
                   :display_downloads => false,
                   :display_last_request_at => false)
      u.role = role # attribute role_id is protected and must be assigned separately
      u.save(false)
    end
end
