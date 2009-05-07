
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

  def self.search(params, args)
    paginate :conditions => search_conditions(params),
                           :order => 'started_at DESC',
                           :page => current_page(params[:page]),
                           :per_page => args[:per_page]
  end

  def self.user_peers(user, params, args)
    paginate_by_user_id user,
                        :conditions => {:seeder => params[:seeding] == '1'},
                        :order => 'started_at DESC',
                        :page => current_page(params[:page]),
                        :per_page => args[:per_page]
  end

  def self.torrent_peers(torrent_id, params, args)
    paginate_by_torrent_id torrent_id,
                           :order => 'started_at DESC',
                           :page => current_page(params[:page]),
                           :per_page => args[:per_page]
  end

  def self.find_for_announce_resp(torrent, announcer, args)
    cols = ['id', 'torrent_id', 'user_id', 'uploaded', 'downloaded', 'leftt', 'port', 'started_at', 'last_action_at']
    find :all,
         :conditions => ['torrent_id = ? AND user_id != ?', torrent.id, announcer.id],
         :order => cols.rand, # simple way to randomize retrieved peers
         :limit => args[:limit]
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

  private

  def self.search_conditions(params)
    s, h = '', {}
    unless params[:user_id].blank?
      s << 'user_id = :user_id '
      h[:user_id] = params[:user_id].to_i
      previous = true
    end
    unless params[:torrent_id].blank?
      s << 'AND ' if previous
      s << 'torrent_id = :torrent_id '
      h[:torrent_id] = params[:torrent_id].to_i
      previous = true
    end
    if params[:seeder] == '1'
      params[:leecher] = '0'
      s << 'seeder = TRUE '
      previous = true
    elsif params[:leecher] == '1'
      s << 'seeder = FALSE '
      previous = true
    end
    unless params[:ip].blank?
      s << 'AND ' if previous
      s << 'ip = :ip '
      h[:ip] = params[:ip]
      previous = true
    end
    unless params[:port].blank?
      s << 'AND ' if previous
      s << 'port = :port '
      h[:port] = params[:port].to_i
    end
    [s, h]
  end
end


