
class CreateForums < ActiveRecord::Migration

  def self.up
    create_table :forums do |t|
      t.column :name, :string, :null => false
      t.column :description, :text
      t.column :topics_count, :integer, :null => false, :default => 0
      t.column :position, :integer, :null => false
      t.column :topics_locked, :boolean, :null => false, :default => false
    end
  end

  def self.down
    drop_table :forums
  end
end