
class CreateRewards < ActiveRecord::Migration

  def self.up
    create_table :rewards do |t|
      t.column :user_id, :integer, :null => false
      t.column :torrent_id, :integer, :null => false
      t.column :amount, 'BIGINT(20)', :null => false
      t.column :created_at, :datetime, :null => false
      t.column :reward_number, :integer, :null => false
    end
  end

  def self.down
    drop_table :rewards
  end
end
