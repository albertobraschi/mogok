
class CreateLogs < ActiveRecord::Migration

  def self.up
    create_table :logs do |t|
      t.column :body, :string, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :admin, :boolean, :null => false, :default => false
    end

    add_index :logs, :created_at
  end

  def self.down
    drop_table :logs
  end
end
