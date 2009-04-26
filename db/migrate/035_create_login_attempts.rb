
class CreateLoginAttempts < ActiveRecord::Migration

  def self.up
    create_table :login_attempts do |t|
      t.column :ip, :string, :null => false
      t.column :attempts_count, :integer, :null => false
      t.column :blocked_until, :datetime
    end
  end

  def self.down
    drop_table :login_attempts
  end
end