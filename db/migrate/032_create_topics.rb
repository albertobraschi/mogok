
class CreateTopics < ActiveRecord::Migration

  def self.up
    create_table :topics do |t|
      t.column :forum_id, :integer, :null => false
      t.column :user_id, :integer
      t.column :title , :string, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :replies_count, :integer, :null => false, :default => 0
      t.column :last_post_at, :datetime, :null => false
      t.column :last_post_by, :string
      t.column :stuck, :boolean, :null => false, :default => false
      t.column :locked, :boolean, :null => false, :default => false
    end    
    add_index :topics, [:stuck, :created_at]
  end

  def self.down
    drop_table :topics
  end
end
