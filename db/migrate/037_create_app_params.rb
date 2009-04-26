
class CreateAppParams < ActiveRecord::Migration

  def self.up
    create_table :app_params do |t|
      t.column :name, :string, :null => false
      t.column :value, :string, :null => false
    end
  end

  def self.down
    drop_table :app_params
  end
end