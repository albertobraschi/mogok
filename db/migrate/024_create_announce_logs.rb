
class CreateAnnounceLogs < ActiveRecord::Migration
  
  def self.up
    create_table :announce_logs do |t|
      t.column :torrent_id, :integer, :null => false
      t.column :user_id, :integer
      t.column :event, :string
      t.column :seeder, :boolean, :null => false, :default => false
      t.column :ip, :string, :null => false
      t.column :port, :integer, :null => false, :limit => 5
      t.column :up_offset, 'BIGINT(20)', :null => false, :default => 0
      t.column :down_offset, 'BIGINT(20)', :null => false, :default => 0
      t.column :created_at, :datetime, :null => false
      t.column :time_interval, 'BIGINT(20)', :null => false, :default => 0
      t.column :client_code, :string
      t.column :client_name, :string
      t.column :client_version, :string
    end

    add_index :announce_logs, :created_at
    add_index :announce_logs, :torrent_id
    add_index :announce_logs, :user_id
    add_index :announce_logs, :ip
  end

  def self.down
    drop_table :announce_logs
  end
end