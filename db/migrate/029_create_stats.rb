

class CreateStats < ActiveRecord::Migration
  
  def self.up
    create_table :stats do |t|
      t.column :created_at, :datetime, :null => false
      t.column :users_active, :integer, :null => false
      t.column :users_inactive, :integer, :null => false
      t.column :peers_seeding, :integer, :null => false
      t.column :peers_leeching, :integer, :null => false
      t.column :torrents_alive, :integer, :null => false
      t.column :torrents_dead, :integer, :null => false
      t.column :snatches, :integer, :null => false
      t.column :forums, :integer, :null => false
      t.column :topics, :integer, :null => false
      t.column :posts, :integer, :null => false
      t.column :uploaded, 'BIGINT(20)', :null => false
      t.column :downloaded, 'BIGINT(20)', :null => false
      t.column :ratio, :decimal, :precision => 20, :scale => 3, :null => false
      t.column :top_contributors, :binary
      t.column :top_uploaders, :binary
    end    
  end

  def self.down
    drop_table :stats
  end
end


  