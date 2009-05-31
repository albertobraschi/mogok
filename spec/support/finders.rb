
def find_user(username)
  User.find_by_username username
end

def find_wish(name)
  Wish.find_by_name name
end

def find_torrent(name)
  Torrent.find_by_name name
end

def find_login_attempt(ip)
  LoginAttempt.find_by_ip(ip)
end

def find_forum(name)
  Forum.find_by_name name
end






