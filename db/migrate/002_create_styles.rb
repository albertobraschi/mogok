
class CreateStyles < ActiveRecord::Migration

  def self.up
    create_table :styles do |t|
      t.column :name, :string, :null => false
      t.column :stylesheet, :string, :null => false
    end
  end

  def self.down
    drop_table :styles
  end
end
