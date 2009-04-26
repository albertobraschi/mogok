
class CreatePosts < ActiveRecord::Migration

  def self.up
    create_table :posts do |t|
      t.column :user_id, :integer
      t.column :topic_id, :integer, :null => false
      t.column :forum_id, :integer, :null => false
      t.column :body, :text, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :edited_at, :datetime
      t.column :edited_by, :string
      t.column :is_topic_post, :boolean, :null => false, :default => false
      t.column :post_number, :integer, :null => false
    end    
    add_index :posts, :created_at
    add_index :posts, :topic_id
  end

  def self.down
    drop_table :posts
  end
end
