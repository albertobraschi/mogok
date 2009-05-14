
class CreateTorrentFulltexts < ActiveRecord::Migration

  def self.up
    create_table :torrent_fulltexts do |t|
      t.column :torrent_id, :integer, :null => false
      t.column :body, :text, :null => false
    end

    execute 'ALTER TABLE torrent_fulltexts ENGINE = MyISAM'
    execute 'CREATE FULLTEXT INDEX fulltext_torrents ON torrent_fulltexts (body)'
  end

  def self.down
    drop_table :torrent_fulltexts
  end
end
