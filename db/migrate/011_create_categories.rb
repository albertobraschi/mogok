
class CreateCategories < ActiveRecord::Migration

  def self.up
    create_table :categories do |t|
      t.column :name, :string, :null => false
      t.column :type_id, :integer, :null => false
      t.column :image, :string
      t.column :position, :integer, :null => false
    end
  end

  def self.down
    drop_table :categories
  end
end
