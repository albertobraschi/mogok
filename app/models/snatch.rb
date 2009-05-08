
class Snatch < ActiveRecord::Base
  belongs_to :torrent
  belongs_to :user

  def self.create(torrent, user)
    snatch = Snatch.new :user => user, :created_at => Time.now
    Snatch.transaction do      
      t = Torrent.find torrent.id, :lock => true
      t.increment :snatches_count
      t.increment :seeders_count
      t.decrement :leechers_count if t.leechers_count > 0
      t.save
      snatch.torrent = t
      snatch.save
    end
    snatch
  end
end
