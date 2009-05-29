
def fetch_type(name)
  Type.find_by_name(name) || Factory(:type, :name => name)
end

def fetch_category(name, type_name = nil)
  Category.find_by_name(name) || Factory(:category, :name => name, :type => fetch_type(type_name))
end

def fetch_format(name, type_name)
  t = fetch_type type_name
  Format.scoped_by_type_id(t.id).find_by_name(name) || Factory(:format, :name => name, :type => t)
end

def fetch_tag(name, category_name)
  c = fetch_category category_name
  Tag.scoped_by_category_id(c.id).find_by_name(name) || Factory(:tag, :name => name, :category => c)
end

def fetch_style(name = nil)
  name ||= 'default'
  Style.find_by_name(name) || Factory(:style, :name => name)
end

def fetch_role(name = nil)
  name ||= Role::USER
  Role.find_by_name(name) || Factory(:role, :name => name)
end

def fetch_user(username, role = nil)
  u = User.find_by_username username
  unless u
    u = Factory(:user, :username => username, :role => (role || fetch_role), :style => fetch_style)
  end
  u
end

def fetch_system_user
  u = User.find_by_id_and_username(1, 'system')
  unless u
    u = Factory.build(:user, :username => 'system', :role => fetch_role(Role::SYSTEM), :style => fetch_style)
    u.id = 1
    u.save!
  end
  u
end

def fetch_torrent(name, owner_username = nil)
  t = Torrent.find_by_name(name)
  unless t
    raise 'fetch_torrent: owner username required' unless owner_username
    t = Factory(:torrent, :name => name, :user => fetch_user(owner_username), :category => fetch_category('music', 'audio'))
  end
  t
end

def fetch_wish(name, owner_username = nil)
  t = Wish.find_by_name(name)
  unless t
    raise 'fetch_wish: owner username required' unless owner_username
    t = Factory(:wish, :name => name, :user => fetch_user(owner_username), :category => fetch_category('music', 'audio'))
  end
  t
end

def fetch_peer(t, u, ip, port, seeder)
  p = Peer.find_by_torrent_id_and_user_id_and_ip_and_port(t, u, ip, port)
  unless p
    p = Factory(:peer, :torrent => t, :user => u, :ip => ip, :port => port, :seeder => seeder, :peer_conn => fetch_peer_conn(ip, port))
  end
  p
end

def fetch_peer_conn(ip, port)
  PeerConn.find_by_ip_and_port(ip, port) || Factory(:peer_conn, :ip => ip, :port => port)
end

def fetch_forum(name)
  Forum.find_by_name(name) || Factory(:forum, :name => name)
end


#
#
#def fetch_torrent_from_file(name, file_name, owner_username = nil)
#  t = Torrent.find_by_name(name)
#  unless t
#    if CACHE_ENABLED
#      while t = Torrent.find_by_info_hash_hex('54B1A5052B5B7D3BA4760F3BFC1135306A30FFD1')
#        t.destroy # force remotion of torrent objects from cache as the test framework bypasses cache_money synchronization
#      end
#    end
#    torrent_file_data = File.new(File.join(TEST_DATA_DIR, 'valid.torrent'), 'rb').read
#    t = Factory.build(:torrent, :name => name, :user => fetch_user(owner_username), :category => fetch_category('music', 'audio'))
#    t.parse_and_save(torrent_file_data, true)
#  end
#  t
#end
