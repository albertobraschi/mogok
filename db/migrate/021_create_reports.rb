
class CreateReports < ActiveRecord::Migration

  def self.up
    create_table :reports do |t|
      t.column :created_at, :datetime, :null => false
      t.column :user_id, :integer, :null => false
      t.column :reason, :text, :null => false
      t.column :target_label, :string, :null => false
      t.column :target_path, :string, :null => false
      t.column :handler_id, :integer
    end
  end

  def self.down
    drop_table :reports
  end
end