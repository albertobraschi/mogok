
class CreateWishFulltexts < ActiveRecord::Migration

  def self.up
    create_table :wish_fulltexts do |t|
      t.column :wish_id, :integer, :null => false
      t.column :body, :text, :null => false
    end

    execute 'ALTER TABLE wish_fulltexts ENGINE = MyISAM'
    execute 'CREATE FULLTEXT INDEX fulltext_wishes ON wish_fulltexts (body)'
  end

  def self.down
    drop_table :wish_fulltexts
  end
end