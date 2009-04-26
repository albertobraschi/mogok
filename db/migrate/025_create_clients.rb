
class CreateClients < ActiveRecord::Migration

  def self.up
    create_table :clients do |t|
      t.column :code, :string, :null => false
      t.column :name, :string, :null => false      
      t.column :banned, :boolean, :null => false, :default => false
      t.column :min_version, :integer
    end
  end

  def self.down
    drop_table :clients
  end
end
