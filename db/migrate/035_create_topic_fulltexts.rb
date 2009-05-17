
class CreateTopicFulltexts < ActiveRecord::Migration

  def self.up
    create_table :topic_fulltexts do |t|
      t.column :topic_id, :integer, :null => false
      t.column :body, :text, :null => false
    end

    execute 'ALTER TABLE topic_fulltexts ENGINE = MyISAM'
    execute 'CREATE FULLTEXT INDEX fulltext_topics ON topic_fulltexts (body)'
  end

  def self.down
    drop_table :topic_fulltexts
  end
end