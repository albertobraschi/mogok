
class CreateLoginBlocks < ActiveRecord::Migration

  def self.up
    create_table :login_blocks do |t|
      t.column :ip, :string, :null => false
      t.column :blocks_count, :integer, :null => false
    end
  end

  def self.down
    drop_table :login_blocks
  end
end