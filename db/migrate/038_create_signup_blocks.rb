
class CreateSignupBlocks < ActiveRecord::Migration

  def self.up
    create_table :signup_blocks do |t|
      t.column :ip, :string, :null => false
      t.column :blocked_until, :datetime, :null => false
    end
  end

  def self.down
    drop_table :signup_blocks
  end
end