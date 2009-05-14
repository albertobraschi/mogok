
class CreateSnatches < ActiveRecord::Migration
  
  def self.up
    create_table :snatches do |t|
      t.column :user_id, :integer
      t.column :torrent_id, :integer, :null => false
      t.column :created_at, :datetime, :null => false
    end

    add_index :snatches, [:user_id, :torrent_id], :unique => true 
    add_index :snatches, :torrent_id
  end

  def self.down
    drop_table :snatches
  end
end
