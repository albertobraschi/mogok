
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

  def eligible_for_reseed_request?
    self.snatches_count > 0 && self.seeders_count <= 1
  end

  def request_reseed(requester, cost, notifications_number)
    Torrent.transaction do
      requester.charge! cost

      notify_reseed_request self.user, requester

      snatches = Snatch.find_all_by_torrent_id self, :order => 'created_at DESC', :limit => notifications_number
      snatches.each {|s| notify_reseed_request s.user, requester }
    end
  end

  def total_peers
    self.seeders_count + self.leechers_count
  end
end
