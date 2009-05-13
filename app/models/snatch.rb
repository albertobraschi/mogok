
class Snatch < ActiveRecord::Base
  belongs_to :torrent
  belongs_to :user

  def self.create(torrent, user)
    snatch = Snatch.new :torrent => torrent, :user => user, :created_at => Time.now
    Snatch.transaction do      
      t = snatch.torrent.lock!
      t.increment :snatches_count
      t.increment :seeders_count
      t.decrement :leechers_count if t.leechers_count > 0
      t.save
      snatch.save
    end
    snatch
  end
end
