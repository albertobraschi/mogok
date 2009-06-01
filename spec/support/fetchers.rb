
# methods that retrieve or create records using the 'machinist' gem

# domain

  def fetch_type(name)
    Type.find_by_name(name) || Type.make(:name => name)
  end

  def fetch_category(name, type_name = nil)
    Category.find_by_name(name) || Category.make(:name => name, :type => fetch_type(type_name))
  end

  def fetch_format(name, type_name)
    t = fetch_type type_name
    Format.scoped_by_type_id(t.id).find_by_name(name) || Format.make(:name => name, :type => t)
  end

  def fetch_tag(name, category_name)
    c = fetch_category category_name
    Tag.scoped_by_category_id(c.id).find_by_name(name) || Tag.make(:name => name, :category => c)
  end

  def fetch_style(name = nil)
    name ||= 'default'
    Style.find_by_name(name) || Style.make(:name => name)
  end

  def fetch_country(name)
    Country.find_by_name(name) || Country.make(:name => name)
  end

  def fetch_role(name = nil)
    name ||= Role::USER
    Role.find_by_name(name) || Role.make(:name => name)
  end

# tracker

  def fetch_peer_conn(ip, port)
    PeerConn.find_by_ip_and_port(ip, port) || PeerConn.make(:ip => ip, :port => port)
  end

  def fetch_client(code)
    Client.find_by_code(code) || Client.make(:code => code, :name => code)
  end



  