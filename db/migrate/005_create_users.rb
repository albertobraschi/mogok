
class CreateUsers < ActiveRecord::Migration
  
  def self.up
    create_table :users do |t|
      t.column :username, :string, :null => false, :limit => 20
      t.column :encrypted_password, :string, :null => false
      t.column :salt, :string, :null => false
      t.column :passkey, :string, :null => false, :limit => 32
      t.column :token, :string, :limit => 32
      t.column :token_expires_at, :datetime
      t.column :role_id, :integer, :null => false
      t.column :tickets, :string
      t.column :uploaded, 'BIGINT(20)', :null => false, :default => 0
      t.column :downloaded, 'BIGINT(20)', :null => false, :default => 0
      t.column :created_at, :datetime, :null => false
      t.column :last_login_at, :datetime
      t.column :last_seen_at, :datetime
      t.column :inviter_id, :integer
      t.column :avatar, :string
      t.column :email, :string, :null => false
      t.column :country_id, :integer
      t.column :style_id, :integer, :null => false
      t.column :gender_id, :integer
      t.column :info, :text
      t.column :staff_info, :text
      t.column :save_sent, :boolean, :default => true
      t.column :delete_on_reply, :boolean, :default => false      
      t.column :display_last_seen_at, :boolean, :default => true
      t.column :display_downloads, :boolean, :default => true
      t.column :active, :boolean, :default => true
      t.column :has_new_message, :boolean, :default => false
    end    
    add_index :users, :username
    add_index :users, :passkey
  end

  def self.down
    drop_table :users
  end
end

