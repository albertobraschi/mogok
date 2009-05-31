
class CreateMappedFiles < ActiveRecord::Migration
  
  def self.up
    create_table :mapped_files do |t|
      t.column :torrent_id, :integer, :null => false
      t.column :name, :string, :null => false
      t.column :path, :string
      t.column :size, 'BIGINT(20)', :null => false
    end
  end

  def self.down
    drop_table :mapped_files
  end
end
