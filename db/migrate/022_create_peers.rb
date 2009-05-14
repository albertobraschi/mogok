
class CreatePeers < ActiveRecord::Migration
  
  def self.up
    create_table :peers do |t|
      t.column :torrent_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
      t.column :uploaded, 'BIGINT(20)', :null => false, :default => 0
      t.column :downloaded, 'BIGINT(20)', :null => false, :default => 0
      t.column :leftt, 'BIGINT(20)', :null => false, :default => 0
      t.column :peer_id, 'VARBINARY(20)'
      t.column :keyy, :string
      t.column :ip, :string, :null => false
      t.column :port, :integer, :null => false, :limit => 5
      t.column :compact_ip, 'VARBINARY(6)'
      t.column :seeder, :boolean, :null => false, :default => false
      t.column :started_at, :datetime, :null => false
      t.column :last_action_at, :datetime, :null => false
      t.column :client_code, :string
      t.column :client_name, :string
      t.column :client_version, :string
      t.column :peer_conn_id, :integer
    end

     add_index :peers, [:torrent_id, :user_id, :ip, :port], :unique => true
     
     # the index below are used mainly for random find (see Peer#find_for_announce_resp)
     add_index :peers, :torrent_id
     add_index :peers, :user_id
     add_index :peers, :port
     add_index :peers, :started_at
     add_index :peers, :last_action_at
  end

  def self.down
    drop_table :peers
  end
end
