
class CreateComments < ActiveRecord::Migration

  def self.up
    create_table :comments do |t|
      t.column :user_id, :integer
      t.column :torrent_id, :integer, :null => false
      t.column :body, :text, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :comment_number, :integer, :null => false
      t.column :edited_at, :datetime
      t.column :edited_by , :string
    end

    add_index :comments, :created_at
    add_index :comments, :torrent_id
  end

  def self.down
    drop_table :comments
  end
end
