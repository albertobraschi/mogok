
class CreateErrorLogs < ActiveRecord::Migration

  def self.up
    create_table :error_logs do |t|
      t.column :created_at, :datetime, :null => false
      t.column :message, :text
      t.column :location, :text      
    end
  end

  def self.down
    drop_table :error_logs
  end
end
