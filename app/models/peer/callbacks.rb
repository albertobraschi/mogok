
class Peer

  # callbacks concern

  before_create :init_new_record
  before_save :set_compact_ip
  after_create :increment_torrent_counters
  after_destroy :decrement_torrent_counters

  private
  
    def init_new_record
      self.started_at = Time.now
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

    def set_compact_ip
      unless self.compact_ip
        ipaddr = IPAddr.new ip
        if ipaddr.ipv4?
          compact_ip = ipaddr.hton
          p = self.port
          compact_port = ''
          until p == 0
            compact_port << (p & 0xFF).chr
            p >>= 8
          end
          self.compact_ip = compact_ip << compact_port.reverse
        end
      end
    end
end