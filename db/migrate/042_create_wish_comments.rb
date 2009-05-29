
class CreateWishComments < ActiveRecord::Migration

  def self.up
    create_table :wish_comments do |t|
      t.column :user_id, :integer
      t.column :wish_id, :integer, :null => false
      t.column :body, :text, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :comment_number, :integer, :null => false
      t.column :edited_at, :datetime
      t.column :edited_by , :string
    end

    add_index :wish_comments, :created_at
    add_index :wish_comments, :wish_id
  end

  def self.down
    drop_table :wish_comments
  end
end
