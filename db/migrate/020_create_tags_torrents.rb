
class CreateTagsTorrents < ActiveRecord::Migration
  
  def self.up
    create_table :tags_torrents, :id => false do |t|
      t.column :tag_id, :integer, :null => false
      t.column :torrent_id, :integer, :null => false      
    end    
    add_index :tags_torrents, [:tag_id, :torrent_id]
    add_index :tags_torrents, :tag_id    
  end

  def self.down
    drop_table :tags_torrents
  end
end