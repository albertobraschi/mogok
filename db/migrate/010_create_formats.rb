
class CreateFormats < ActiveRecord::Migration
     
  def self.up
    create_table :formats do |t|
      t.column :name, :string, :null => false
      t.column :type_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :formats
  end
end
