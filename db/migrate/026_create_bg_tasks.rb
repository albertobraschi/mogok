
class CreateBgTasks < ActiveRecord::Migration

  def self.up
    create_table :bg_tasks do |t|
      t.column :name, :string, :null => false
      t.column :interval_minutes, :integer
      t.column :next_exec_at, :datetime
      t.column :active, :boolean, :null => false, :default => true
    end
  end

  def self.down
    drop_table :bg_tasks
  end
end

