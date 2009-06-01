
require 'ping'

class Peer < ActiveRecord::Base
  concerns :callbacks, :finders

  belongs_to :user
  belongs_to :torrent
  belongs_to :peer_conn

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

  def self.create(attributes)
    p = new
    p.set_attributes attributes
    p.set_connectivity
    p.save!
    logger.debug ':-) peer created'
    p
  end

  def refresh_announce(attributes)
    set_attributes attributes
    set_connectivity
    save!
    logger.debug ':-) peer updated'
  end

  def set_attributes(h)
    self.torrent        = h[:torrent]
    self.user           = h[:user]
    self.ip             = h[:ip]
    self.port           = h[:port]
    self.uploaded       = h[:uploaded]
    self.downloaded     = h[:downloaded]
    self.leftt          = h[:left]
    self.seeder         = h[:seeder]
    self.peer_id        = h[:peer_id]
    self.last_action_at = h[:current_action_at]
    self.client_code    = h[:client].code
    self.client_name    = h[:client].name
    self.client_version = h[:client].version
  end

  def set_connectivity
    # note: orphaned peer_conns are supposed to be wiped by a background task
    if new_record?
      self.peer_conn = PeerConn.find_by_ip_and_port(self.ip, self.port) || PeerConn.new(:ip => self.ip, :port => self.port)
    end
    if self.peer_conn.connectable.nil? # also if not new peer but a previous check was timeouted
      self.peer_conn.connectable = Ping.pingecho(self.peer_conn.ip, 5, self.peer_conn.port) # nil if timeouted
      self.peer_conn.save
    end
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
      compact_ip << compact_port.reverse
    end
  end
end


