
class CreateWishes < ActiveRecord::Migration
  
  def self.up
    create_table :wishes do |t|
      t.column :category_id, :integer, :null => false
      t.column :format_id, :integer
      t.column :name, :string, :null => false
      t.column :description, :text
      t.column :year, :integer, :limit => 4
      t.column :country_id, :integer
      t.column :created_at, :datetime, :null => false
      t.column :user_id, :integer
      t.column :filled, :boolean, :null => false, :default => false
      t.column :filler_id, :integer
      t.column :filled_at, :datetime
      t.column :total_bounty, 'BIGINT(20)', :null => false, :default => 0
      t.column :bounties_count, :integer, :null => false, :default => 0
      t.column :comments_count, :integer, :null => false, :default => 0
      t.column :comments_locked, :boolean, :null => false, :default => false
    end

    add_index :wishes, :category_id
  end

  def self.down
    drop_table :wishes
  end
end