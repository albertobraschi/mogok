
class CreateWishBounties < ActiveRecord::Migration

  def self.up
    create_table :wish_bounties do |t|
      t.column :user_id, :integer
      t.column :wish_id, :integer, :null => false
      t.column :amount, 'BIGINT(20)', :null => false
      t.column :created_at, :datetime, :null => false
      t.column :bounty_number, :integer, :null => false
      t.column :revoked, :boolean, :null => false, :default => false
    end

    add_index :wish_bounties, :created_at
    add_index :wish_bounties, :wish_id
  end

  def self.down
    drop_table :wish_bounties
  end
end
