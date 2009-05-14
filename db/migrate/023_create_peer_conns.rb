
class CreatePeerConns < ActiveRecord::Migration

  def self.up
    create_table :peer_conns do |t|
      t.column :ip, :string, :null => false
      t.column :port, :integer, :null => false, :limit => 5
      t.column :connectable, :boolean
    end

    add_index :peer_conns, [:ip, :port], :unique => true 
  end

  def self.down
    drop_table :peer_conns
  end
end
