
require 'ping'

class Peer < ActiveRecord::Base
  concerns :callbacks, :finders

  belongs_to :user
  belongs_to :torrent
  belongs_to :peer_conn

  def init_attributes(announce_req)
    self.torrent = announce_req.torrent
    self.user = announce_req.user
    self.ip = announce_req.ip
    self.port = announce_req.port
    self.compact_ip = self.class.make_compact_ip self.ip, self.port
    set_attributes(announce_req)
  end

  def set_attributes(announce_req)
    self.uploaded = announce_req.uploaded
    self.downloaded = announce_req.downloaded
    self.leftt = announce_req.left
    self.seeder = announce_req.seeder
    self.peer_id = announce_req.peer_id
    self.last_action_at = announce_req.current_action
    self.client_code = announce_req.client.code
    self.client_name = announce_req.client.name
    self.client_version = announce_req.client.version
  end

  def set_connectivity
    # note: orphaned peer_conns should be wiped by a background task
    if new_record?
      self.peer_conn = PeerConn.find_by_ip_and_port(self.ip, self.port) || PeerConn.new(:ip => self.ip, :port => self.port)
    end
    if self.peer_conn.connectable.nil? # also if not new peer and previous check was timeouted
      self.peer_conn.connectable = Ping.pingecho(self.peer_conn.ip, 5, self.peer_conn.port) # nil if timeouted
      self.peer_conn.save
    end
  end

  def connectable?
    self.peer_conn.connectable
  end

  def completion_percentage
    if self.leftt == 0
      return 100
    elsif self.torrent.size == self.leftt
      return 0
    else
      ((self.torrent.size - self.leftt) / self.torrent.size.to_f) * 100
    end
  end

  def self.delete_inactives(threshold)
    destroy_all ['last_action_at < ?', threshold]
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


