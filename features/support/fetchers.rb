
def fetch_role(name)
  r = Role.find_by_name(name)
  unless r
    r = Role.new :description => name, :css_class => "user_#{name}"
    r.name = name
    r.save
  end
  r
end

def fetch_style(name)
  Style.find_by_name(name) || Style.create(:name => name, :stylesheet => "#{name}.css")
end

def fetch_type(name)
  Type.find_by_name(name) || Type.create(:name => name)
end

def fetch_category(name, type_name = nil)
  if type_name
    t = fetch_type type_name
    Category.scoped_by_type_id(t.id).find_by_name(name) || Category.create(:name => name, :type_id => t.id, :position => 1)
  else
    Category.find_by_name(name)
  end
end

def fetch_format(name, type_name = nil)
  if type_name
    t = fetch_type type_name
    Format.scoped_by_type_id(t.id).find_by_name(name) || Format.create(:name => name, :type_id => t.id)
  else
    Format.find_by_name(name)
  end
end

def fetch_tag(name, category_name = nil)
  if category_name
    c = fetch_category category_name
    Tag.scoped_by_category_id(c.id).find_by_name(name) || Tag.create(:name => name, :category_id => c.id)
  else
    Tag.find_by_name(name)
  end
end

def fetch_login_attempt(ip, create = true)
  a = LoginAttempt.find_by_ip(ip)
  if a.nil? && create
    a = LoginAttempt.create(:ip => ip, :attempts_count => 0)
  end
  a
end

def fetch_peer(torrent, user, ip, port, seeder)
  p = Peer.find :first,
                :conditions => {:torrent_id => torrent, :user_id => user, :ip => ip, :port => port}
  unless p
    p = Peer.new
    p.torrent = torrent
    p.user = user
    p.ip = ip
    p.port = port
    p.seeder = seeder
    p.started_at = Time.now
    p.last_action_at = Time.now
    p.peer_conn = PeerConn.create(:ip => ip, :port => port)
    p.save
  end
  p
end

def fetch_user(username, role = nil, email = nil)
  u = User.find_by_username username
  unless u
    raise "role required when trying to create user [#{username}]" unless role
    u = build_user(username, role, email)
    u.save
  end
  u
end

def fetch_system_user
  system_role = fetch_role Role::SYSTEM
  u = build_user('system', system_role)
  u.id = 1
  u.save
  u
end

private

  def build_user(username, role, email = nil)
    u = User.new
    u.username = username
    u.password = username
    u.password_confirmation = username
    u.role = role
    u.created_at = Time.now
    u.email = email || "#{username}@mail.com"
    u.style = fetch_style('default')
    u
  end




