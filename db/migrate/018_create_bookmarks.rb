
class CreateBookmarks < ActiveRecord::Migration
  
  def self.up
    create_table :bookmarks do |t|
      t.column :user_id, :integer, :null => false
      t.column :torrent_id, :integer, :null => false
    end

    add_index :bookmarks, [:user_id, :torrent_id], :unique => true 
    add_index :bookmarks, :torrent_id
  end
  
  def self.down
    drop_table :bookmarks
  end
end