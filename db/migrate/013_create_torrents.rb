
class CreateTorrents < ActiveRecord::Migration
  
  def self.up
    create_table :torrents do |t|
      t.column :category_id, :integer, :null => false
      t.column :format_id, :integer
      t.column :name, :string, :null => false
      t.column :description, :text
      t.column :year, :integer, :limit => 4
      t.column :country_id, :integer
      t.column :info_hash, 'VARBINARY(20)', :null => false
      t.column :info_hash_hex, :string, :null => false # used as cache key (binary is problematic on memcached)
      t.column :size, 'BIGINT(20)', :null => false
      t.column :created_at, :datetime, :null => false
      t.column :user_id, :integer
      t.column :files_count, :integer, :null => false
      t.column :snatches_count, :integer, :null => false, :default => 0
      t.column :comments_count, :integer, :null => false, :default => 0
      t.column :seeders_count, :integer, :null => false, :default => 0
      t.column :leechers_count, :integer, :null => false, :default => 0
      t.column :active, :boolean, :null => false, :default => true
      t.column :locked, :boolean, :null => false, :default => false
      t.column :announce_key, :string, :limit => 10, :null => false
      # meta info
      t.column :creation_date, :datetime
      t.column :created_by, :string, :limit => 50
      t.column :comment, :string, :limit => 100
      t.column :encoding, :string, :limit => 20
      t.column :piece_length, :integer, :null => false
      t.column :dir_name, :string
    end  
    add_index :torrents, :created_at
    add_index :torrents, :info_hash_hex
    add_index :torrents, :name
    add_index :torrents, :seeders_count
    add_index :torrents, :leechers_count     
  end

  def self.down
    drop_table :torrents
  end
end