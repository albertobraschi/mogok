
class CreateMessages < ActiveRecord::Migration

  def self.up
    create_table :messages do |t|
      t.column :owner_id, :integer, :null => false
      t.column :sender_id, :integer, :null => false
      t.column :receiver_id, :integer, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :subject, :string, :null => false
      t.column :body, :text
      t.column :unread, :boolean, :null => false, :default => true 
      t.column :folder, :string, :null => false, :limit => 15
    end

    add_index :messages, [:folder, :owner_id]
    add_index :messages, :created_at    
  end

  def self.down
    drop_table :messages
  end
end