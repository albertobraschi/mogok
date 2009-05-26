
class Peer

  # callbacks concern

  before_create :init_new_record
  after_create :increment_torrent_counters
  after_destroy :decrement_torrent_counters, :debug_destroyed

  private
  
    def init_new_record
      self.started_at = Time.now
      self.compact_ip = self.class.make_compact_ip self.ip, self.port
    end

    def increment_torrent_counters
      t = self.torrent.lock!
      if seeder?
        t.increment! :seeders_count
      else
        t.increment! :leechers_count
      end
    end

    def decrement_torrent_counters
      t = self.torrent.lock!
      if seeder?
        t.decrement! :seeders_count if t.seeders_count > 0
      else
        t.decrement! :leechers_count if t.leechers_count > 0
      end
    end

    def debug_destroyed
      logger.debug ':-) peer destroyed'
    end
end