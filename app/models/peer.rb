
class Peer < ActiveRecord::Base
  belongs_to :user
  belongs_to :torrent
  belongs_to :peer_conn  

  def after_create
    t = Torrent.find self.torrent_id, :lock => true
    t.increment! :seeders_count if seeder?
    t.increment! :leechers_count unless seeder?
    self.torrent = t
  end

  def before_destroy
    t = Torrent.find self.torrent_id, :lock => true
    t.decrement! :seeders_count if seeder? && t.seeders_count > 0
    t.decrement! :leechers_count if !seeder? && t.leechers_count > 0
  end

  def set_attributes(announce_req)
    self.torrent = announce_req.torrent
    self.user = announce_req.user
    self.uploaded = announce_req.uploaded
    self.downloaded = announce_req.downloaded
    self.leftt = announce_req.left
    self.seeder = announce_req.seeder
    self.peer_id = announce_req.peer_id
    self.ip = announce_req.ip
    self.port = announce_req.port
    self.compact_ip = Peer.make_compact_ip announce_req.ip, announce_req.port
    self.last_action_at = announce_req.current_action
    self.client_code = announce_req.client.code
    self.client_name = announce_req.client.name
    self.client_version = announce_req.client.version
  end

  def completion_percentage
    return 100 if self.leftt == 0
    return 0 if self.torrent.size == self.leftt
    sprintf "%.1f", ((self.torrent.size - self.leftt) / self.torrent.size.to_f) * 100
  end

  def self.make_compact_ip(ip, port)
    ipaddr = IPAddr.new ip
    if ipaddr.ipv4?
      compact_ip = ipaddr.hton
      p = port
      compact_port = ''
      until p == 0
        compact_port << (p & 0xFF).chr
        p >>= 8
      end
      return compact_ip << compact_port.reverse
    end
    return nil
  end
end


