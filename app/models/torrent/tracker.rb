
class Torrent

  # tracker concern


  def add_snatch(user)
    unless Snatch.find_by_user_id_and_torrent_id(user, self)
      Torrent.transaction do
        Snatch.create :torrent => self, :user => user
        lock!
        increment :snatches_count
        increment :seeders_count
        decrement :leechers_count if self.leechers_count > 0
        save
      end
      logger.debug ':-) torrent snatch registered'
    else
      logger.debug ':-) torrent already snatched by user'
    end
  end

  def total_peers
    self.seeders_count + self.leechers_count
  end
end
